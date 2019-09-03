# Create the account
```bash
$ curl https://api.skynetng.pw/user -X POST -d '{ "username": "kainlite+test@gmail.com", "password": "Testing123@"  }'
OUTPUT:
{
  "user": {
    "CodeDeliveryDetails": {
      "AttributeName": "email",
      "DeliveryMedium": "EMAIL",
      "Destination": "k***+***t@g***.com"
    },
    "UserConfirmed": false,
    "UserSub": "317e9839-e9ee-4969-855d-1c13ac79662c"
  }
}
```

# Validate the account, this would be normally done from a webapp or mobile app, but since we're not doing the frontend we need a way to test it.
```bash
$ curl https://api.skynetng.pw/user/validate -X POST -d '{ "username": "kainlite+test@gmail.com", "code": "680641"  }'
OUTPUT:
{ "status": "Confirmed" }
```

# Once the account is confirmed, we craft this file with the login details to get an access token (Authentication).
```bash
$ cat auth.json
OUTPUT:
{
    "AuthParameters": {
        "USERNAME": "kainlite+test@gmail.com",
        "PASSWORD": "Testing123@"
    },
        "AuthFlow": "USER_PASSWORD_AUTH",
        "ClientId": "4o2gst5o56074cc4af90vpeujk"
}
```

# Then we issue this curl call to actually get the token.
```bash
$ curl -X POST --data @auth.json -H 'X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth' -H 'Content-Type: application/x-amz-json-1.1' https://cognito-idp.us-east-1.amazonaws.com/ | jq
OUTPUT:
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4037  100  3883  100   154   3476    137  0:00:01  0:00:01 --:--:--  3614
{
  "AuthenticationResult": {
    "AccessToken": "eyJraWQiOiJJMVN1Q0VteVlVXC9OSkFVY2lLOWRNeE1VSUJzTHZDYm9KejBaaGozZG5SND0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI5ZDMzNDk1MC1mOGIzLTRlZjMtOTVlYy0wNWYzODQxN2UxNTEiLCJldmVudF9pZCI6Ijc2MDVjMTI3LTcwMmItNDI3OS04ZWU5LWQyOGUxY2ZiZjVmYSIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiYXdzLmNvZ25pdG8uc2lnbmluLnVzZXIuYWRtaW4iLCJhdXRoX3RpbWUiOjE1Njc0NjI0NDAsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX3IwdWdoOUR1cSIsImV4cCI6MTU2NzQ2NjA0MCwiaWF0IjoxNTY3NDYyNDQwLCJqdGkiOiJlMzE0MmJkMC02ZjQ0LTQyNGMtOTExNy01ZTg3NWZhOTg1MDQiLCJjbGllbnRfaWQiOiI0bzJnc3Q1bzU2MDc0Y2M0YWY5MHZwZXVqayIsInVzZXJuYW1lIjoiOWQzMzQ5NTAtZjhiMy00ZWYzLTk1ZWMtMDVmMzg0MTdlMTUxIn0.TjuOR6naiWKYQvuS3gNM8PJXVlL3wqg6TwNGAHqnJ5HzSRx5sQX2bbLUtY1qB7vwACyqQEdYObgGyc8CpV65yNZ9NeNjnCE4wfJMLpSRNXdTQeDpCqNlLVTC8wN33A_ksq1zqTllXRbSODk6rv3trBMs_phJqpDRdxeWR7fsgOwh8J6BcRxg-LhUYRh_IF7EQpFkbOlDi5MAQiz-8-koHf84r75fs28yIT15LVQWcwYXNoS5mUFYdHxuUKsuagdO5VremsT-Y1NQEcwUwe8JL-UwGtVv18IXHk_qrE8uovJiJ7zDKeuEah6ycI1jgTaGBBVLqCBXgf2Nb5XRJ77BUA",
    "ExpiresIn": 3600,
    "IdToken": "eyJraWQiOiJKbzNWczRLS0FmcXNtOGFlVVNPSzJcLzdcL2JweGUwNkV2Vk9nRnlcL3Njb2VZPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI5ZDMzNDk1MC1mOGIzLTRlZjMtOTVlYy0wNWYzODQxN2UxNTEiLCJhdWQiOiI0bzJnc3Q1bzU2MDc0Y2M0YWY5MHZwZXVqayIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiZXZlbnRfaWQiOiI3NjA1YzEyNy03MDJiLTQyNzktOGVlOS1kMjhlMWNmYmY1ZmEiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NzQ2MjQ0MCwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLnVzLWVhc3QtMS5hbWF6b25hd3MuY29tXC91cy1lYXN0LTFfcjB1Z2g5RHVxIiwiY29nbml0bzp1c2VybmFtZSI6IjlkMzM0OTUwLWY4YjMtNGVmMy05NWVjLTA1ZjM4NDE3ZTE1MSIsImV4cCI6MTU2NzQ2NjA0MCwiaWF0IjoxNTY3NDYyNDQwLCJlbWFpbCI6ImthaW5saXRlQGdtYWlsLmNvbSJ9.RuwjyG_y4AgBkAVD29scmW8zF3nANGjrDt33v4wOIGAxH0nWbIDc9lMDCS57mOb02LwglyqlsJXGt-BCgjXdKvumjbehAu_a9E3KZlAjA7l4anoSHoIPN_gU5DmiBhL67OTRr4bZxQjTup6abloWt0sqiUx_gA5okH3VNi1oooCIVQ1GfJ53mxhtdUB1LiHpJ7aIwDYDqLFrrNj8f2I4r0oomAkFSEt6DjpEKXI33tCUj9AI-n9JH2wcgsvVAPGIjryfWDrgb8sEujhoZq-AjOHb3ri2B8aWnx0-DQTAVKVnxwBQZH8YAK0r2oLNxhIqZDCUEXaMpzYcDjjG83kA3Q",
    "RefreshToken": "eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVAifQ.OupuJR3hZUT2bWQTA0n2YqIxN6Lqphxv_yZXjAaJSIKub66xuiF1axUFC9h9SEroWedqR0id_vmfbfH_71_EyS0HZjUlyXSde3WXefY9Yc2YNK1ChCR4rh33r3neuQg0hKx63JTIMVf9yWeFl1Mx4KEsA4eTyvN6GE8o54lGNX6fQX7KovuG5rH0iZQVb2oPFglokAk2uCB4M6p2SbUtWLO5oZYOPWwax62JHb2b5EEwDW4aAJEoWjVetbjLnQHLedYv9Ur68XeSKRtrslZAdCyFjD6Rc1oxuuBEi590CJgj3tlpJV7rSE_185NB90Sa6uU728sksub9sxnANUDY3A.jXKGBg26M4uE3dWm.qO7BO568Aa-4U55mvR-7_1CMCk7ZN7clBAVfKkFyDz6LXwkki9V2ohvm4f_joN88htr4p7AFV7Rik23-vTtTgPXVI9vBUIt37EXyjaMKPJX3B15XnYnC1-YhxjGma6IiyC1oUuiCmUIm9L1c7Jxm8ZmCBFNjc-ARXJTvWAHB3eYHk6U3WHOSB9X_MT2K9Dmrl1-q1vjP4taUKlj60jy91uwk0Ti8tVHp7ETpe4DyEcv9EuoFtEznrJDYcnYpVLyaq9Fkb43F7L3kMq_Jx4IAbWhCaeC35JJa56zAZ1eZ_mGuC5T86xChNqDElhod6m_pz33j5OyPL8rXh8ldERbB7cBB1QgePbPlr1GOvC2T8mE1Rb_gvzNU05Nm1VaeXnClV39GFBpGpEfKY6uvnWiZZICTE3LZRDIhI8Cn-9LwkAUMzqQRKYcPGZswZ68Ma_H40xB3A8pyw_RMF_QvZurUumg-RDeFS2CSnW12zhtMQhr_60Jt9vRQCbWVjBcTh40ZBO5TE8IHsulPq5uJaBEhY2_lpIga4HHjI6cqZ7J3PkRjTc6ZNzAaJiGY0cdRi2pXTeiLqm5_04BUzVbfBQytURbYoaYLxv_wXT-gR4JTLewxJyouO4l955GXK2IjXdZxyFmaXaKrKs7UuiRrkc65_Xzbn8Gj9u0beN661W1CsdymYNht5RfFsJMh85IhsxmzR7XM_2kDVQIjo5EZq5XV0SKQmVjFPYuUIQKcdkx0UsQzQisuuZarcWoDSNq-rxWJF2JbzjtkPyoaSaPxlwC8TL4HXQvT5HQ9S6VeSp0PTQj2BV4NtqzEpskJ9Nql3xrn488WpZD7NBeWkkA_bBKKiYDALoXjmEd6yvmehVtP1VBoqszHOMbikLa1FakJIGpbXqtaH3ZvLdrVCFTKCoEtMob_c4YKoiRgoqyAXew-H_znrxHagVLnJRqfYXLVFkjxGm23PKvSRSRsUXNIlBwUrh8hwL4rsyZLPTE-8aAiG-6VmVE3Xg-JvMtftC-MC5W5PAjLACf_hJP97FrCtg65dUY4-GCGnGMmbe-yLx7z0YaKzuGxccwyT08E-zfmVCeBrkeA-4niUt3xcTJkOOKnPycMWG437cFPxp7sEjw0f4CnZfwX7YHO2rB78UODCZIIqbXgmSQgt86HxNLDqcKY0gLQCIVd3VQSgyRTjOefE3BUGqUHmJ5fKt207tYq_YN6R6rKUvD6NFORmqXIY3AnfU3W1c0FF5ta56T_MW9XSxmcX5AzmT1ZUuzsuNA7gImdu9cpYabynLZgXKSIvcfix__vO84X8bWzr06McPMtRWvLmOr8X5RF9u3X7Q.WVY_SyQ6pF_ae5YP1ov2tg",
    "TokenType": "Bearer"
  },
  "ChallengeParameters": {}
}
```

# And to validate that we can authenticate users with our code we finally fetch the profile
```bash
$ curl https://api.skynetng.pw/user/profile -X POST -d '{ "access_token": "very_long_access_token_from_the_previous_command" }'
OUTPUT:
{
  "profile": {
    "MFAOptions": null,
    "PreferredMfaSetting": null,
    "UserAttributes": [
      {
        "Name": "sub",
        "Value": "317e9839-e9ee-4969-855d-1c13ac79662c"
      },
      {
        "Name": "email_verified",
        "Value": "false"
      },
      {
        "Name": "email",
        "Value": "kainlite@gmail.com"
      }
    ],
    "UserMFASettingList": null,
    "Username": "317e9839-e9ee-4969-855d-1c13ac79662c"
  },
  "user": {
    "access_token": "eyJraWQiOiJJMVN1Q0VteVlVXC9OSkFVY2lLOWRNeE1VSUJzTHZDYm9KejBaaGozZG5SND0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI5ZDMzNDk1MC1mOGIzLTRlZjMtOTVlYy0wNWYzODQxN2UxNTEiLCJldmVudF9pZCI6Ijc2MDVjMTI3LTcwMmItNDI3OS04ZWU5LWQyOGUxY2ZiZjVmYSIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiYXdzLmNvZ25pdG8uc2lnbmluLnVzZXIuYWRtaW4iLCJhdXRoX3RpbWUiOjE1Njc0NjI0NDAsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX3IwdWdoOUR1cSIsImV4cCI6MTU2NzQ2NjA0MCwiaWF0IjoxNTY3NDYyNDQwLCJqdGkiOiJlMzE0MmJkMC02ZjQ0LTQyNGMtOTExNy01ZTg3NWZhOTg1MDQiLCJjbGllbnRfaWQiOiI0bzJnc3Q1bzU2MDc0Y2M0YWY5MHZwZXVqayIsInVzZXJuYW1lIjoiOWQzMzQ5NTAtZjhiMy00ZWYzLTk1ZWMtMDVmMzg0MTdlMTUxIn0.TjuOR6naiWKYQvuS3gNM8PJXVlL3wqg6TwNGAHqnJ5HzSRx5sQX2bbLUtY1qB7vwACyqQEdYObgGyc8CpV65yNZ9NeNjnCE4wfJMLpSRNXdTQeDpCqNlLVTC8wN33A_ksq1zqTllXRbSODk6rv3trBMs_phJqpDRdxeWR7fsgOwh8J6BcRxg-LhUYRh_IF7EQpFkbOlDi5MAQiz-8-koHf84r75fs28yIT15LVQWcwYXNoS5mUFYdHxuUKsuagdO5VremsT-Y1NQEcwUwe8JL-UwGtVv18IXHk_qrE8uovJiJ7zDKeuEah6ycI1jgTaGBBVLqCBXgf2Nb5XRJ77BUA"
  }
}
```
