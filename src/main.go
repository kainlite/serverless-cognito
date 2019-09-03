package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws/external"
	"github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider"

	"github.com/aws/aws-sdk-go/aws"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/gin-gonic/gin"
)

var ginLambda *ginadapter.GinLambda

type User struct {
	AccessToken string `json:"access_token"`
}

func getProfile(c *gin.Context) {
	user := User{}
	err := c.BindJSON(&user)

	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"err": err.Error(),
		})
		return
	}

	cfg, err := external.LoadDefaultAWSConfig()
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"err": err.Error(),
		})
		return
	}

	cognito := cognitoidentityprovider.New(cfg)
	req := cognito.GetUserRequest(&cognitoidentityprovider.GetUserInput{
		AccessToken: aws.String(user.AccessToken),
	})

	resp, err := req.Send(c)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"err": err.Error(),
		})
		return
	}

	c.JSON(http.StatusAccepted, gin.H{
		"user": resp,
	})
}

type UserPassword struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func createUser(c *gin.Context) {
	user := UserPassword{}
	err := c.BindJSON(&user)

	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"err": err.Error(),
		})
		return
	}

	cfg, err := external.LoadDefaultAWSConfig()
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"err": err.Error(),
		})
		return
	}

	cognito := cognitoidentityprovider.New(cfg)
	req := cognito.SignUpRequest(&cognitoidentityprovider.SignUpInput{
		ClientId:       aws.String(os.Getenv("COGNITO_CLIENT_ID")),
		Username:       aws.String(user.Username),
		Password:       aws.String(user.Password),
		ValidationData: []cognitoidentityprovider.AttributeType{cognitoidentityprovider.AttributeType{Name: aws.String("email")}},
	})

	resp, err := req.Send(c)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"err": err.Error(),
		})
		return
	}

	c.JSON(http.StatusAccepted, gin.H{
		"user": resp,
	})
}

type UserValidation struct {
	Username string `json:"username"`
	Code     string `json:"code"`
}

func validateUser(c *gin.Context) {
	user := UserValidation{}
	err := c.BindJSON(&user)

	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"err": err.Error(),
		})
		return
	}

	cfg, err := external.LoadDefaultAWSConfig()
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"err": err.Error(),
		})
		return
	}

	cognito := cognitoidentityprovider.New(cfg)
	req := cognito.ConfirmSignUpRequest(&cognitoidentityprovider.ConfirmSignUpInput{
		ClientId:         aws.String(os.Getenv("COGNITO_CLIENT_ID")),
		Username:         aws.String(user.Username),
		ConfirmationCode: aws.String(user.Code),
	})

	resp, err := req.Send(c)
	if err != nil {
		log.Println(resp, err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"err": err.Error(),
		})
		return
	}

	c.JSON(http.StatusAccepted, gin.H{
		"status": "Confirmed",
	})
}

func init() {
	log.Printf("Gin cold start")
	r := gin.Default()
	r.POST("/user/validate", validateUser)
	r.POST("/user", createUser)
	r.POST("/user/profile", getProfile)

	r.GET("/app/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "healthy",
		})
	})

	ginLambda = ginadapter.New(r)
}

func Handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	return ginLambda.ProxyWithContext(ctx, req)
}

func main() {
	lambda.Start(Handler)
}
