# =========================
# 1️⃣ BUILD STAGE
# =========================
# FROM node:22 AS build
FROM node:22-slim AS build

# install dependencies
# RUN apt-get update && apt-get install -y \
#     bash \
#     gettext-base \
#     openssh-client \
#     git \
#     --no-install-recommends \
#     && rm -rf /var/lib/apt/lists/*

# create app directory
WORKDIR /app

# copy everthing
COPY . .

# Create SSH directory and add GitHub to known_hosts
# RUN mkdir -p ~/.ssh && \
#     ssh-keyscan github.com >> ~/.ssh/known_hosts

# List files in ~/.ssh/
# RUN ls -la ~/.ssh

# COPY ssh_keys/ /root/.ssh
# RUN chmod 600 /root/.ssh/id_rsa
# RUN ssh-keyscan github.com >> ~/.ssh/known_hosts

# Clone submodule
# RUN git submodule update --progress --init --recursive
# RUN git -C ./bifi_app checkout angularv20

# Run config.library.sh
# RUN sh ./bifi_app/tools/config/config-library.sh --libs projects tasks helpdesk calendar inventory website purchases sales --title=APP

# Run build
RUN npm run build

# =========================
# 2️⃣ NGINX STAGE
# =========================
FROM nginx:stable AS deploy

# Clean default config
RUN rm /etc/nginx/conf.d/default.conf

# copy nginx
# COPY ./bifi_app/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/nginx.conf /etc/nginx/conf.d/default.conf

# copy dist
COPY --from=build /app/dist/*/browser /usr/share/nginx/html

# expose port
EXPOSE 8080

# run nginx
CMD ["nginx", "-g", "daemon off;"]
