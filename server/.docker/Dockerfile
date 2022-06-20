# Here we are getting our node as Base image
FROM node:16.15-alpine

# Update Node Path
ENV PATH $PATH:/app/node_modules/.bin

# setting working directory in the container
RUN mkdir /app
WORKDIR /app

# copy project dependency file with lock
COPY package.json package-lock.json ./

# installing the dependencies into the container
RUN npm ci

# NOTE: the content of the server folder needs to be mounted 
# as a volume in /home/node_user/app

# command to run within the container
CMD ["/bin/sh", "./.scripts/entrypoint.dev.sh"]
