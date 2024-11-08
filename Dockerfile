FROM node:22-bookworm-slim as build
RUN apt update && apt install -y git && apt clean
RUN git clone -n --depth=1 --filter=tree:0 https://github.com/misskey-dev/misskey && \
    cd misskey && \
    git sparse-checkout set --no-cone packages/backend packages/misskey-js packages/misskey-reversi packages/meta.json .config/ && \
    git checkout
RUN cd /misskey/packages/misskey-reversi && yarn --dev && yarn build && \
    cd ../misskey-js && yarn --dev && yarn build && \
    cd ../backend && yarn add ../misskey-reversi ../misskey-js && yarn --dev && yarn build

FROM node:22-bookworm-slim
COPY --from=build --chown=node:node /misskey/.config /.config
COPY --from=build --chown=node:node /misskey/packages/meta.json /built/meta.json
COPY --from=build --chown=node:node /misskey/packages/backend /fedired/backend
USER node
COPY ./default.yml /.config/default.yml
WORKDIR /fedired/backend
COPY ./entrypoint.sh .
EXPOSE 3000
ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]
