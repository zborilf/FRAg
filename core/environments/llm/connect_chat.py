# -*- coding: utf-8 -*-

import openai

def ask_gpt(prompt):

    from openai import OpenAI
    client = OpenAI()
    openai.api_key = "your_api_key"
    response = client.chat.completions.create(
        model= "gpt-4.1",
        messages=[{"role":"user", "content": prompt}]
    )
    return response.choices[0].message.content


