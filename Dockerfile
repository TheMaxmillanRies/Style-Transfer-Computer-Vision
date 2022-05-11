FROM ubuntu:20.04

# create a non-root user
# RUN adduser ureason

# install root dependencies
RUN apt-get update && apt-get -y update \
    && apt-get install -y apt-utils build-essential python3.8 python3-pip python3-dev \
    && pip3 -q install pip --upgrade

# create a workfolder for jupyter notebooks
RUN mkdir -p src/app
# navigate to workfolder
WORKDIR src/
# copy files to workfolder
COPY ./requirements.txt .

# grant new user permissions
# RUN chown -R ureason:ureason .
# USER ureason

# Install jupyter and dependencies
RUN pip3 install jupyter \
    && pip3 install -r requirements.txt \
    && pip install -U scikit-learn \
    && pip install seaborn \
    && pip install torch==1.10.1+cpu torchvision==0.11.2+cpu torchaudio==0.10.1 -f https://download.pytorch.org/whl/torch_stable.html

# set notebook work directory
COPY ./ /src/app/
WORKDIR /src/app

# execute startup command
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
