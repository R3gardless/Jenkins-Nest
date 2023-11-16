# Use Node.js as the base image
FROM node:latest

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy Nest.js application source code
COPY src ./src
COPY tsconfig.json ./
COPY tsconfig.build.json ./
COPY nest-cli.json ./

# If you have Prisma files, copy them too
COPY prisma ./prisma

# Define the command to start your application (modify as needed)
CMD ["npm", "run", "start:dev"]
