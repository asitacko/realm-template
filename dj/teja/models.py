from django.db import models


class User(models.Model):
    name = models.TextField(max_length=255)
    email = models.EmailField()
    password = models.TextField()
    # more than once status can be stored in this field?
    # email_not_confirmed
    # pending_approval
    # approved
    # left_company
    status = models.TextField(default="email_not_confirmed")

    created_on = models.DateTimeField(auto_now_add=True)
    updated_on = models.DateTimeField(auto_now=True)


class Session(models.Model):
    # what would be the value of session id? encrypted_id.
    user = models.ForeignKey(User, on_delete=models.PROTECT)
    last_ip = models.TextField(max_length=39)
    user_agent = models.TextField(max_length=1024)

    created_on = models.DateTimeField(auto_now_add=True)

    # Would we update this on every http request? no, only when last_ip or user_agent
    # changes. session timeout would be managed by cookie age, which will be extended
    # by 30 days on every request
    updated_on = models.DateTimeField(auto_now=True)
