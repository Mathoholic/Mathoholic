---
layout: post
title: "Beginner's Guide to Machine Learning"
date: 2024-06-22 04:16:16 +0530
excerpt: "This series of articles will make machine learning easier to understand with resources to learn in depth. Learn what machine learning is, how it works, and the 7 essential steps in the ML process."
tags: [MachineLearning, AI, DataScience, BeginnerGuide]
author: "Shantanu Sharma"
slug: "machine-learning-01"
---

This series of articles will make machine learning easier to understand with resources to learn in depth.

### What is machine learning?

There are complex definitions available which defines machine learning in more technical and mathematical terms. To start with a simple one we will consider this one :

> Machine Learning is the field of study that gives computer the ability to learn without being explicitly programmed.
> 
> ~ [Arthur Samuel](https://www.forbes.com/sites/gilpress/2021/05/28/on-thinking-machines-machine-learning-and-how-ai-took-over-statistics/), Computer Scientist

Samuel's definition of machine learning, distinguishes it from traditional programming. If you are programmer you must know that in programming the rules to deal with input data are definied and on the basis of those rules our program generates output. Machine learning flips this whole paradigm.

In machine learning, data points and their corresponding correct answers (labels) are provided to coomputer. The computer uses this information to learn patterns and rules. So we don't make rules here. These learned rules allows the computer to predict the correct answers for new and unseen data. Machine learning is data driven process.

![Machine Learning Process](https://cdn.hashnode.com/res/hashnode/image/upload/v1719029548992/14370fb3-5314-4247-95d2-b4d8635b0981.png)

### How machine learning works?

As machine learning is data driven process, data of good quality is of great importance to build a efficient machine learning solution. The process of machine learning involves seven broad steps.

1. **Data Collection:**
    
    The step for gathering data is foundation of machine learning process. The quality and quantity of data that we gather directly determines how well or badly the model will work.
    
2. **Preparing the Data:**
    
    This step involves data wrangling to remove duplicates, correct the errors, deal with missing values, data type conversions and so on. We use data visualization techniques, to see relevant relationships between the different attributes and check for outliers. To select the right attributes for the model. The data is randomised so that the order of data do not effect what is learned. Another important step is to divide data into two parts. The larger part (~80%) would be used for training the model and the smaller part is used for the evaluation of trained model's performance.
    
3. **Choose a model:**
    
    Data Scientist around the world have developed models for different purpose and goals. In the existing models out there we select the model which suits our purpose and goal well.
    
4. **Training:**
    
    The step of Training, involves running the model on the prepared dataset, allowing the model to learn from it and make predictions. While the model process the data, it tries to find the hidden pattern.
    
    The training process involves starting with some random values for the model's parameters, say X and Y. The model uses these values to make predictions, which are then compared to the actual correct answers. Based on this comparison, the model adjusts X and Y to improve its predictions. This process repeats, and each cycle of updating is called a training step.
    
    The training process is iterative, meaning the model will continually learn and improve as it processes more data.
    
5. **Evaluation:**
    
    The part of dataset created for evaluation is used to check the model's proficiency. This puts the model in a scenario where it encounters situations that were not part of its training.
    
6. **Fine-Tuning:**
    
    After we have evaluated the model's performance, we can still improve its accuracy by fine-tuning certain parameters. These parameters, which were set implicitly during the initial training, can be adjusted to enhance the model's predictions further. This process of adjusting parameters to optimize the model's performance is known as parameter tuning or hyperparameter tuning.
    
    These hyperparameters might include how fast our model learns (learning rate), the number of layers in a neural network, or the number of groups it makes in clustering alogrithm.
    
    To do this (fine-tuning) we try different combination of these settings and see how well the model performs. The goal is to find the best combination of settings. There are several ways to tune hyperparameters:
    
    * **Grid Search:** Test all possible combinations.
        
    * **Random Search:** Test a random selection of combinations.
        
    * **Bayesian Optimization:** Use a smart method to predict which combinations will work best.
        
7. **Deployment & Monitoring:**
    
    Once the model is trained and its hyperparameters are optimized, it is integrated into a production environment where it can start making predictions on new, unseen data. Often, models are deployed as part of a web service, accessible via APIs (Application Programming Interfaces) so other applications can send data to the model and receive predictions.
    
      
    We continuously monitor the model's performance to ensure it maintains accuracy and efficiency. This involves tracking metrics such as prediction accuracy, response time, and resource usage. The model is re-trained periodically so that it remains up-to-date.
    
      
    The final step ensure that model remains useful, reliable, and relevant in its production environment.
    

## Bibliography

Doshi, R., & Hiran, K. K. (2021). [*Machine Learning*](https://amzn.to/3RDvVag). Paperback.