# Style Transfer via Variational Autoencoder

## Introduction
Style transfer is an algorithmic process that manipulates digital images or videos, in order to adopt the artisitic style of another image. Style transfer algorithms are characterized by the use of deep neural netowrks for the sake of image transformation and abstract feature extraction. These style transfer algorithms are commonly used to create digital artworks, for example by transferring the visual appearance of famous paintings to realistic photographs.  In this article, we will reproduce the algorithm described below, and expand on its work by attempting to substituting the specified neural network architecture. Once the substituion is done, we compare our variation of the network with the original one and similar methods fine tuned specifically on stain glass art. A detailed comparison is presented at the end of the blog. 

## First contribution - Reproduce the paper:
in this part, we explain briefly the main parts of the paper then show the results we managed to get by reproducing the paper. 

### Main Process of the paper:

The style transfer work by Zhi-Song Liu et al., known as [Style Transfer via Variational AutoEncoder (ST-VAE)](https://arxiv.org/pdf/2110.07375.pdf), builds on the concept that the style images can be projected into a linear latent space, allowing them to be merged via simple interpolation. From a general point of view, it consists of an Image encoder that learns a represenation of the input image in latent space. Then a middle part of the network does some processing operations of the latent representation of the image, then learns a variation encoder that enables the network to sample uniformly from the latent representation of the image. Next, the middle part of the network applies some post processing steps to finally get to the Image decoder where the output is the fused image with style transfered from one image to another. A detailed overview of the architecture will follow in the sections below. 

#### Image Autoencoder:
The image autoencoder is the fundamental building block upon which this network is designed. Baseing itself on prior works, Zhi-Song Liu et al. used a VGG-19 network without the fully connected layers as an encoder to project the content and style images into a latent space. With a matching decoder, the network was trained on the COCO dataset to learn how to project any image into a latent space and recreate it thereafter. 
The main purpose of the Image Autoencoder is to ensure that each image has a unique and compact set of features.

#### VAE-based Linear Transformation (VLT)
The VLT system is responsible for the latent space-based style manipulation. In short, the VLT learns the covariance matrices of the input images via a linear transformation module. The style images are then passed on to the Variational Module, before multiplying its output with the content features.

![model](https://user-images.githubusercontent.com/45178285/172070465-e17a0076-5935-47d5-8716-12d465eaf428.png)

#### Main Pipeline:

The image above demonstrates the pipeline of the style transfer. Using the Image Encoder (blue), the content and style images are projected into a latent space. In order to achieve this, the IAE is pretrained using the COCO dataset, and frozen for the style transfer process.
Using the estimated covariance matrices calculated at the beginning of the VLT box (yellow), the styles are projected onto a Gaussian space (purple), before being fused into the content image features.
Finally, the Image Decoder (blue) is used to project the stylized image back into an image space.

To train this large network to learn how to parameterize the Variational Autoencoder, a pretrained VGG-16 network is used, where the content, style, and stylized image are passed through the network and input into a customized loss function. This loss function makes use of a Gram matrix to create a modified MSE loss.


#### Steps to reproduce the paper:

The first part of our pojoect was to reproduce the ST-VAE paper. Fortunately, the main code base of the paper was publicly available on GitHub. However, the code was outdated and had some missing parts. We, first, made the code work and behave as it is supposed to which helped us to understand clearly the code base to be able to tweak it and change it for our second contribution as explained in the next subsection. This part of the project didn't take much time from the team but we got some aesthetically nice results. 

The main issues that we have faced are the outdated dependecies in their code base, the lack of relation between the paper and the code base. For example, in the paper, there is only one mention of VGG-19 (that we frankly missed when reading the paper). Fortunately, by re-reading the paper several times and mapping its steps to the code base's steps, we managed to make it work.

#### Results:
We provide some examples images of the ST-VAE work, our contribution, and other methods we chose to compare our work with, later in this blog.


## Second contribution - Expand on ST-VAE by using ResNet-50 instead of VGG-19:
In this section of the blog, we present our second contribution. It consisted of replacing the VGG-19 autoencoder in the main architecture of ST-VAE with a custom made ResNet-50 autoencoder. 

### Motivation for this contribution:
Since the first contribution didn't take us a lot of time (it was done in the first 2 weeks of the course), we wanted to try to expand on the work of ST-VAE. Figuring out if another architecture for the autoencoder will drastically change ST-VAE's ability to transfer style from one image to another. More specifically,  we wanted to see if residual connections of a ResNet-50 autoencoder affect the quality of the image, compared to the usage of a VGG network. We chose to replace the Image Autoencoder from a VGG-19 network to a ResNet-50 network (without the fully connected layers). 

We chose ResNet-50 for two reasons, it is relatively a small architecture and there are several pre-trained ResNet-50 architectures available online that we can use for quick tests. We first wanted to train this variation of the architecture ourselves but unfortunately, we couldn't do that. More information about this will be discussed later in the blog. 

### Building a custom ResNet-50 AutoEncoder:
To fulfill this step of our process, we coded our own version of ResNet-50 AutoEncoder. Fortunately, the main building blocks for ResNet-50 are available on GitHub (especially for the encoder part of the Autoencoder). We, quickly, built the encoder then we dived into building the reverse of the encoder to create the decoder part. This has proved to be a little bit difficult but, fortunately, we were able to finish it succefully.


### Connecting the custom ResNet-50 AutoEncoder to the ST-VAE architecture:
The main and next challenge was connecting our custom built ResNet-50 autoencoder to the input and output of the VLT in the ST-VAE. It consisted of connecting the latent space manipulations performed by both the VLT and the Variational Module with the new latent space dimensions provided by the ResNet encoder. Unsurprisingly, the output of ResNet-50 encoder is different than the one used by VGG-19. Therefore, we had to overhaul the entirety of their latent space code base, effectively altering the loss functions, as well as the latent space dimension manipulations. We tried to limit the changes to the loss function to be able to compare the results of the paper to the new variantion we have built. In a similar fashion, we had to change the dimensions of the output of the loss function to be compatible with the input of the ResNet-50 decoder. This part of the project proved to be one of the most difficult ones and took us most of the time during the time of the project. 
Additionally, the VLT module made use of specific dimension squeeze() and unsqueeze() methods, which were not compatible with the ResNet-50 latent space. This change was also difficult to correct for, as our initial solutions, while valid mathematically, produced noise-only outputs.


### Running and testing the new variation of the ST-VAE architecture:
Once everything was connected with minimal changes to the main ST-VAE architecture, we directly started testing the newly built variation. Here are some of the results of our variation and their counterparts from ST-VAE. 
 
<table>
    <tr>
        <th></th>
        <th>Original image </th>
        <th>Style image </th>
        <th>ST-VAE</th>
        <th>Our variation</th>
    </tr>
    <tr>
        <td>
            Example 1
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173199456-07e6e284-0b86-4b96-9be2-743cd3284270.jpeg'  width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173199543-5806a644-53c8-44d6-a081-08e4aa1259fe.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173199430-75c665f0-272b-4f0d-a305-ac8233f4e98b.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173199441-2a8a70e3-55b1-461d-b94e-402be0669c5a.jpeg' width="200"   height="200">
        </td>
    </tr>
    <tr>
        <td>
            Example 2
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173200326-47c68cdf-6ddf-4086-8b4b-0971ecf821d7.jpeg'  width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173200317-f93fafb7-b946-4278-9e86-9988fc0c9d16.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173200339-bfeaaf7c-2ab9-433a-9b44-d663a2c34874.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173200595-e7caf285-08c8-4395-97fc-d5418aedfba4.jpeg' width="200"   height="200">
        </td>
    </tr>
    <tr>
        <td>
            Example 3
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173200380-0866c7e3-61ab-4d84-9fc2-176cf446c736.jpeg'  width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173200378-a91289c1-fb8a-494a-b620-a39dcca4418b.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173200363-24a88e6a-48aa-416f-a23f-28e76a2973ed.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173200597-f940316d-1924-45c6-bcb6-46c45e5105d9.jpeg' width="200"   height="200">
        </td>
    </tr>
</table>

### Comparing the results of our variation with the original ST-VAE and limitations:
One thing is clear from the results above, our ResNet-50 variation produces results where a lot of information from the content images is lost(which can be considered less than optimal compared to the ST-VAE results). However, upon close inspection of the images, you can see some patterns from the original image showing up in the results of the ResNet-50 variation. In fact, the woman in the first example can be seen in the results of our variation. The same goes for the pillars of the TU Delft library and for the silhouette of the D&D character. Below, we clearly show where you can see the patterns. 

<table>
    <tr>
        <th>Example 1 </th>
        <th>Example 2 </th>
        <th>Example 3</th>
    </tr>
    <tr>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173201009-a1c937ca-18ca-4a76-a2f5-77a9f7fbb03b.jpeg'  width="400"   height="300">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173201060-73c56e23-c94c-4053-925a-ceaa548e5804.jpeg' width="400"   height="300">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173201091-b71cc348-cce4-4d9f-b102-17d3681a9994.jpeg' width="400"   height="300">
        </td>
    </tr>
    <tr>
        <th>The woman is slightly visible in the image</th>
        <th>The pillars of the library can be seen in the image in parallel </th>
        <th>The silhouette of the character is slightly visible especially the curvature of the head</th>
    </tr>
</table>

Even though some parts of the image can still be seen in the results, this is far from the results we were expecting. We try to explain these results in the following limitations: 

#### No training was done:
A very large limitation we experienced was time. Due to the limited time we had to work on this project, we could not successfully train our ResNet Autoencoder on the COCO dataset, forcing us to use an arbitrary set of pretrained weights from the internet. More precisely, we used the `resnet50-19c8e357.pth` pre-trained weights for our AutoEncoder. This can explain why a lot of important information of the features are lost when transfering the style. With more time, we would have been able to train properly the model and maybe we could have got better results.

#### Changes to the Linear transfer and Variation modules:
In order to connect the custom ResNet-50 Autoencoder to the Linear transfer and Variation modules, we had to make several changes. Mainly, we had to alter the loss function and change the dimensions of input and output of the modules. Since these changes were not backed by any mathematical proofs as they did in the original paper, these changes might be at the core of our problem. Maybe with more time to study the influence of the changes and trying better solutions other than just making the code work by changing the dimensions of the output can be a solution to this problem and can be used to show that a ResNet-50 autoencoder can indeed replace a VGG-19. 

#### A ResNet-50 autoenceoder is maybe not the way to go?
Our decision to try a ResNet-50 autoencoder instead of a VGG-19 is not related to any works or studies. It was just curiosity from our side to see if we can make it work and if it does work at all. So a possible cause of the bad results might be that our initial choice was not correct and ResNet-50 cannot replace VGG-19 in this setting. We cannot conclude this for sure until the previous two limitations are overcome. However, we did get some small good results where parts of the images were still in there. So maybe it is a good idea that just needs more time and fine tuning. 

## Third contribution - Comparing ST-VAE, our variation and three other methods:
We had still one week in the project time when we got the results shown above. Therefore, we wanted to contribute a little bit more in our project. Therefore, we decided to do a third contribution where we compare the techniques and methods used in ST-VAE and our variation to three other methods. In this section, we will first present briefly three methods then we will compare their methods and results to the previous results. For the three methods, while we did reproduce the code, we had access to existing github repositories, which provided clear instructions how to set things up. One interesting side-note, is that most neural style transfer methods in PyTorch use a very old version where .lua files were still used to store model weights. This made reproducing the projects much more difficult, due to the very confusing PyTorch version documentation. 


### Method 1: [Neural-Style-Transfer](https://github.com/titu1994/Neural-Style-Transfer)
This repository builds upon the work of Gatys et al. "A Neural Algorithm of Artistic Style", a prior work which our original papers builds on and references. The main idea behind the algorithm of Gatys et al. is to effectively overfit a network to a content and style image, where the statistics of the recreated image are matched to both the content and style image. This is effectively done by using a VGG-19 convolutional network, and relying on its intermediate layers.
As is beginning to be understood in deep learning, the initial few layer activations represent low-level features such as edges and textures, while the later layer activations present higher-level features, such as object components (boxes, eyes. etc...). By using these intermediate layers are reference, the algorithm of Gatys et al. effectively aims to match, for an input image, the corresponding style and content target intermediate representations.




### Method 2: [neural-style-tf](https://github.com/cysmith/neural-style-tf)
The works presented in this paper is both a reproduction of Gatys et al. "A Neural Algorithm of Artistic Style", as well as an improvement on top of it, by incorporating an additional improvement for color preservation. While the works of Method 1 and 2 are very similar, they differ in the method with which they try to match the image statistics.

For Method 1, the key observation made related to the high-frequency details which were present in the output image. When creating the output image, it was observed that a lot of noise was present, notably in the presence of arbitrary and unnecessary edges. This specific case was notably observed in stained glass images. As a solution to this issue, Method 1 used a Sobel filter-based regulation to reduce the number of edges and preserve a smoother image.

What Method 2 aimed to achieve is the preservation and uniformity of colors. By specifically preserving colors by using specific intermediate layers of the full VGG network (Method 1 only used 1 intermediate layer which was hand-picked), the output is smoother, with the edge information being better preserved.



### Method 3: [Neural style transfer](https://github.com/titu1994/Neural-Style-Transfer)
In truth, this method is a bit of a mystery. This Github repository also refers to the paper of Gatys et al., however builds upon it differently as well, by incorporating works relating to "Neural Doodles". Neural Doodles is an older work for style transfer and art creation by using a Neural Patch algorithm to draw doodles. This Neural Patches algorithm makes use of generative Markov rnadom field models (MRF), which are descriminatively trained CNN's for synthesizing 2D images. Unfortunately, due to time limitations, we did not have the time to further investigate the specifics behind this work. It is however a very intruiging work, as drawing using a computer is very different from fusing two images.

### Comparison of the methods' results
In the table below, we present the results of the three methods using the same examples shown in the previous section. 

<table>
    <tr>
        <th></th>
        <th>Original image </th>
        <th>Style image </th>
        <th>Method 1</th>
        <th>Method 2</th>
        <th>Method 3</th>
    </tr>
    <tr>
        <td>
            Example 1
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173199456-07e6e284-0b86-4b96-9be2-743cd3284270.jpeg'  width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173199543-5806a644-53c8-44d6-a081-08e4aa1259fe.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173203407-31d8359e-5939-4732-940c-54e7aac6a951.png' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173227940-83f067ab-e1a2-4a82-b1c0-ee1fce56286a.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173203098-0574eb73-3501-4636-bc3c-c97877ed6a22.png' width="200"   height="200">
        </td>
    </tr>
    <tr>
        <td>
            Example 2
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173200326-47c68cdf-6ddf-4086-8b4b-0971ecf821d7.jpeg'  width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173200317-f93fafb7-b946-4278-9e86-9988fc0c9d16.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173202590-f28b641e-4649-43c0-acdb-c2b86a896cb1.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173202595-5d203e14-449f-42d0-9e40-e414dbc1fe22.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173203072-87d8163e-0f79-4f41-bc39-a4c910d80ab4.png' width="200"   height="200">
        </td>
    </tr>
    <tr>
        <td>
            Example 3
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173200380-0866c7e3-61ab-4d84-9fc2-176cf446c736.jpeg'  width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173200378-a91289c1-fb8a-494a-b620-a39dcca4418b.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173202601-1cecfcef-f88c-44dc-b0a0-b19f3b3cd15f.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173227820-c27a5fa8-7489-4029-aaf4-6128ce81930a.jpeg' width="200"   height="200">
        </td>
        <td>
            <img src='https://user-images.githubusercontent.com/45178285/173203083-6d5e680b-2f1d-4ddb-afad-983b3bb38f81.png' width="200"   height="200">
        </td>
    </tr>
</table>

Overall, observing the results of the three methods, we can easily see the difference between the methods. Method 1 and 3 both have images which consist of "fusions" of the style and content images in the pure mathematical sense. Both methods have rounded shapes and interpolated smooth colors between objects. Method 2 on the other hand, has an artistic style which is very close to what one would expect for stained glass art. The edges are sharp and minimalist, with the colors being roughly uniform within each geometric set. This applies especially to the first image generated, where the entire room is very smoothly turned into a stained glass art which looks realistic. 

What is interesting to observe beyond the qualitative measurements, is how these images are evaluated. In most works based on mathematics, notably for classification and segmentation, the loss values and error output is a strong indicator of the performance of the method and its correctness. For the problem of style transfer, and artistic generation as a whole, the method for evaluating the best algorithm is not based on a quantitative measurement, but purely on the personal preference of the majority. For all works related to this project, the results were often obtained by asking a group of individuals to select which image they found best. And what is most interesting, is that even the networks with the lowest Mean Square Error can still easily be considered worse.

## Conclusion
Overall, this project was in hindsight, a bit too ambitious for our budgetary and time limitations. While we finally succeeded in connecting the ResNet-50 to the VLT module and modifying the loss functions to allow the code to run, we did not have the time to extensively experiment and test the benefits of the residual connection-based architecture.
A very interesting expansion we were hoping to have time to try, was the use of a timeseries-based modification to allow the editing of videos with smooth and continuous artistic style. As can be shown on the 3 images below, while the style transfer technology is applicable to videos frame-by-frame, the continuous complete change of image can induce headaches and a detachement from the format.
