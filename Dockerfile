FROM debian

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get install --no-install-recommends -y \
    curl \
    gnupg2 \
    libguestfs-tools \
    linux-image-amd64 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY scripts /scripts
WORKDIR /scripts

RUN curl -LO https://kinvolk.io/flatcar-container-linux/security/image-signing-key/Flatcar_Image_Signing_Key.asc \
    && gpg --import Flatcar_Image_Signing_Key.asc

VOLUME [ "/out" ]

ENTRYPOINT [ "/scripts/entrypoint.sh" ]
CMD [ "echo", "Done!" ]