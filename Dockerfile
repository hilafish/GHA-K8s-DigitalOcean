# Start from a base image with Go already installed
FROM golang:alpine

WORKDIR /app

COPY . .

RUN go build -o main .

EXPOSE 8080

CMD ["./main"]