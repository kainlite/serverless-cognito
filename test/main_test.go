package test

import (
	"crypto/tls"
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

// An example of how to test the Terraform module in examples/terraform-aws-example using Terratest.
func TestTerraformAwsExample(t *testing.T) {
	t.Parallel()

	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	// awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	awsRegion := "us-east-1"

	workingDir := "../terraform"

	// At the end of the test, undeploy the web app using Terraform
	defer test_structure.RunTestStage(t, "cleanup", func() {
		destroyTerraform(t, workingDir)
	})

	// Deploy the web app using Terraform
	test_structure.RunTestStage(t, "deploy", func() {
		deployTerraform(t, awsRegion, workingDir)
	})

	// Validate that the ASG deployed and is responding to HTTP requests
	test_structure.RunTestStage(t, "validate", func() {
		validateAPIGateway(t, workingDir)
	})
}

// Validate that the API Gateway has been deployed and is working
func validateAPIGateway(t *testing.T, workingDir string) {
	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	// Run `terraform output` to get the value of an output variable
	url := terraform.Output(t, terraformOptions, "URL")

	// It can take a few minutes for the API GW and CloudFront to finish spinning up, so retry a few times
	//	maxRetries := 30
	timeBetweenRetries := 15 * time.Second

	// Setup a TLS configuration to submit with the helper, a blank struct is acceptable
	tlsConfig := tls.Config{}

	// Verify that the API Gateway returns a proper response
	apigw := retry.DoInBackgroundUntilStopped(t, fmt.Sprintf("Check URL %s", url), timeBetweenRetries, func() {
		http_helper.HttpGetWithCustomValidation(t, fmt.Sprintf("%s/app/health", url), &tlsConfig, func(statusCode int, body string) bool {
			return statusCode == 200
		})
	})

	// Stop checking the API Gateway
	apigw.Done()
}

// Deploy the resources using Terraform
func deployTerraform(t *testing.T, awsRegion string, workingDir string) {
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,
	}

	// Save the Terraform Options struct, instance name, and instance text so future test stages can use it
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}

// Destroy the resources using Terraform
func destroyTerraform(t *testing.T, workingDir string) {
	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	terraform.Destroy(t, terraformOptions)
}
