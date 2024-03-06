from django.shortcuts import render
from django.http import HttpResponse
from polls.models import Question

# Create your views here.


def index(request):
    qs = Question.objects.all().count()
    return HttpResponse(f"Questions: {qs}")