from django.db import models
from django.conf import settings
from the_user_app.models import CustomUser


class Task(models.Model):
  user = models.ForeignKey(settings.AUTH_USER_MODEL,related_name='created_tasks', on_delete=models.CASCADE)
  created_at = models.DateTimeField(auto_now_add=True)
  title = models.CharField (max_length=30)
  description = models.CharField(max_length=255)
  when_is = models.DateTimeField()
  assignee = models.ForeignKey(settings.AUTH_USER_MODEL, related_name='assigned_tasks', on_delete=models.CASCADE)
  is_accepted = models.BooleanField(default=False)
  def __str__(self):
        return self.title