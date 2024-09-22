FROM node:20-alpine

WORKDIR /frontend

COPY . .

RUN npm install
RUN yarn build

CMD ["yarn", "start"]
