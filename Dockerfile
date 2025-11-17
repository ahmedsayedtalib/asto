FROM python

WORKDIR /app
COPY . .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python3", "manage.py", "runserver", "0.0.0.0:5000"]

