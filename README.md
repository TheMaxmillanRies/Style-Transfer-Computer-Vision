# Style Transfer via Variational Autoencoder

## Introduction
Style transfer is an algorithmic process that manipulates digital images or videos, in order to adopt the artisitic style of another image. Style transfer algorithms are characterized by the use of deep neural netowrks for the sake of image transformation and abstract feature extraction. These style transfer algorithms are commonly used to create digital artworks, for example by transferring the visual appearance of famous paintings to realistic photographs. In this article, we will reproduce the algorithm described below, and expand on its work by attempting to substituting the specified neural network architecture.

![](readme/fig2.png)
> [**Multiple Style Transfer via Variational AutoEncoder**](https://arxiv.org/abs/2110.07375),            
> Zhi-Song Liu, Vicky Kalogeiton and Marie-Paule Cani,        
> *arXiv technical report ([arXiv 2110.07375](https://arxiv.org/abs/2110.07375))*  


    @article{DBLP:journals/corr/abs-2110-07375,
        author    = {Zhi{-}Song Liu and
               Vicky Kalogeiton and
               Marie{-}Paule Cani},
         title     = {Multiple Style Transfer via Variational AutoEncoder},
         journal   = {CoRR},
        volume    = {abs/2110.07375},
        year      = {2021},
        url       = {https://arxiv.org/abs/2110.07375},
        eprinttype = {arXiv},
        eprint    = {2110.07375},
        timestamp = {Fri, 22 Oct 2021 13:33:09 +0200},
        biburl    = {https://dblp.org/rec/journals/corr/abs-2110-07375.bib},
        bibsource = {dblp computer science bibliography, https://dblp.org}}


## Abstract

Modern works on style transfer focus on transferring style from a single image. Recently, some approaches study multiple style transfer; these, however, are either too slow or fail to mix multiple styles. We propose ST-VAE, a Variational AutoEncoder for latent space-based style transfer. It performs multiple style transfer by projecting nonlinear styles to a linear latent space, enabling to merge styles via linear interpolation before transferring the new style to the content image. To evaluate ST-VAE, we experiment on COCO for single and multiple style transfer. We also present a case study revealing that ST-VAE outperforms other methods while being faster, flexible, and setting a new path for multiple style transfer.



## Features at a glance

- **One-sentence method summary:** Our model takes a content image, a style image, and combines then using multiple autoencoders to create a styled content image.

- The model can directly be applied to any kind of content and style image, as it is not reliant on training data, but clever usage of autoencoders.

- Easily extendable to video stylizing, by classifying frame-by-frame. Could further be extended to an LSTM structure to allow smooth transition between frames.

## Main Process

The style transfer work by Zhi-Song Liu et al., known as Style Transfer via Variational AutoEncoder (ST-VAE), builds on the concept that the style images can be projected into a linear latent space, allowing them to be merged via simple interpolation.

#### Image Autoencoder
The image autoencoder is the fundamental building block upon which this network is designed. Baseing itself on prior works, Zhi-Song Liu et al. used a VGG-19 network without the fully connected layers as an encoder to project the content and style images into a latent space. With a matching decoder, the network was trained on the COCO dataset to learn how to project any image into a latent space and recreate it thereafter. 
The main purpose of the Image Autoencoder is to ensure that each image has a unique and compact set of features.

#### VAE-based Linear Transformation (VLT)
The VLT system is responsible for the latent space-based style manipulation. In short, the VLT learns the covariance matrices of the input images via a linear transformation module. The style images are then passed on to the Variational Module, before multiplying its output with the content features.

![model](https://user-images.githubusercontent.com/45178285/172070465-e17a0076-5935-47d5-8716-12d465eaf428.png)

#### Main Pipeline

The image above demonstrates the pipeline of the style transfer. Using the Image Encoder (blue), the content and style images are projected into a latent space. In order to achieve this, the IAE is pretrained using the COCO dataset, and frozen for the style transfer process.
Using the estimated covariance matrices calculated at the beginning of the VLT box (yellow), the styles are projected onto a Gaussian space (purple), before being fused into the content image features.
Finally, the Image Decoder (blue) is used to project the stylized image back into an image space.

To train this large network to learn how to parameterize the Variational Autoencoder, a pretrained VGG-16 network is used, where the content, style, and stylized image are passed through the network and input into a customized loss function. This loss function makes use of a Gram matrix to create a modified MSE loss.


## Our Contribution

### Reproducing the paper
The first part of our porject was to reproduce the ST-VAE paper. Fortunately, the main code base of the paper was publicly available on GitHub. However, the code was outdated and had some missing parts. We, first, made the code work and behave as it is supposed to which helped us to understand clearly the code base to be able to tweak it and change it for our second contribution as explained in the next subsection. This part of the project didn't take much time from the team but we got some estheticly nice results. 

Below are some images created from both single style and multiple style transfer.

**Images here**

### Expand on ST-VAE by using ResNet-50 instead of VGG-19
The main motivation behind our contribution was to try create a ResNet Autoencoder and see if the residual connections affect the quality of the image, compared to the usage of a VGG network. We chose to replace the Image Autoencoder from a VGG-19 network to a ResNet-50 network (without the fully connected layers). 

While the initial process appeared to be straightforward, with the definition of the ResNet-50 architecture being wisdespread on Github, we quickly found the assimilation process to be difficult.

The main setback we experienced consisted of connecting the latent space manipulations performed by both the vLT and the Variational Module with the new latent space dimensions provided by the ResNet encoder.

To do this, we had to, first, implement an ResNet encoder that unsuprinsignly output a different dimension than the VGG-19 encoder. We, then, had to to change the loss function slightly to be able to work with the new dimensions of the ResNet encoder. We tried to limit the changes to the loss function to be able to compare the results of the paper to the new variantion we have built. In a similar fashion, we had to change the dimensions of the output of the loss function to be compatible with the input of the ResNet-50 decoder. **More is needed here**


## Comparison Image Quality

## Limitations
A very large limitation we experienced was time. Due to the limited time we had to work on this project, we could not successfully train our ResNet Autoencoder on the COCO dataset, forcing us to use an arbitrary set of pretrained weights from the internet. **More on not being able to fully train**


## Conclusion
Overall, this project was in hindsight, a bit too ambitious for our budgetary and time limitations. While we finally succeeded in connecting the ResNet-50 to the VLT module and modifying the loss functions to allow the code to run, we did not have the time to extensively experiment and test the benefits of the residual connection-based architecture.
A very interesting expansion we were hoping to have time to try, was the use of a timeseries-based modification to allow the editing of videos with smooth and continuous artistic style. As can be shown on the 3 images below, while the style transfer technology is applicable to videos frame-by-frame, the continuous complete change of image can induce headaches and a detachement from the format.
