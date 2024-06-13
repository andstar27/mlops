FROM python:3.11
WORKDIR /pythonProject2
COPY . /pythonProject2
RUN pip install -r requirements.txt
CMD ["python3", "-m", "chainlit", "run", "chatbot.py", "--port", "8080", "--host", "0.0.0.0"]