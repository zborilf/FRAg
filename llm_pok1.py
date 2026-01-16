# -*- coding: utf-8 -*-

import openai

def connect_chat():
  openai.api_key = "your_api_key"
  response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Jaká fakta jsou v databázi?"}]
  )
  print(response["choices"][0]["message"]["content"])

