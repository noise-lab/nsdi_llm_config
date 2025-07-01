### Meta Comments

### Experimental Revisions:

- Use more state-of-the-art baseline for flow-statistics.
- Include comparison to adaptive ensemble network traffic identification.
- Enrich the experiments for comparative studies and more in-depth analysis.
- Add more comparisons to state-of-the-art solutions.

AC-DC evaluation related:

- Carry out a sensitivity analysis of MPR.
- Detail and evaluate the benefits of dynamic classifier selection compared to just using static early flow features.
- Elucidate the overhead of the online phase.

Generally:

- Include more metrics (accuracy, precision, and recall) and case studies.

### Writing Revisions

System design:

- Provide a solid justification for design choices (e.g. packet choices, flow sizes, ML algorithm choices).
- Clarify the dynamic classifier selection: the paper is actually selecting features and batch sizes.
- Enhance the system and implementation details.
- Explain the practicality of memory requirement search.
- Explain the retraining process.
- Clarify the optimality of the proposed algorithm and scheduler.
- Discuss algorithm adaptability to changes in traffic type.
- Elaborate more on AC-DC details: The paper should provide more details about AC-DC, such as the ensemble learning approach and various features. Explain the implementation of ensemble learning, consider discussing other potential models for AC-DC, and clarify the classification task of AC-DC.
- Discuss the relevance of AC-DC with advancing technology like parallel computing and ML cores.

Feature Related:

- Explain the feature set and emphasize the feature space is not small - each bit is treated as a bit.
- Justify the choice of network features.

Motivation/Baselines/Evaluation:

- Clarify the motivation/evaluation methodology.
- Reduce the critique of established datasets.
- Clarify dataset in motivation evaluation: The motivation evaluation does not describe the dataset used. Make sure to refer the reader to the appropriate table or section.
- Explain high TTD in packet-capture method.
- Justify the traffic rate range.
- Clarify default batch-size assumption for baselines.

### Detailed Reviews

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Review #682A
===========================================================================
Pros:
I think the general directions and high-level designs that this paper have are quite valid: 1) using features from a few packets in a flow, and 2) dynamically choose classifiers, and they are improvements over existing systems. 

Cons:
Many of the designs lack proper justification:
Why is the first three packets important and sufficient for a flow?
What would be the impact of flow sizes? e.g., for an elephant flow, would three packets in the beginning be enough? For mice flows, there may not even be three packets.
Another design that I find unconvincing is "the specific choice of the ML algorithm is less significant" as said at the bottom of the left column on page 6. No reason is given for this statement, and LightGBM is chosen without any justification either. In general, the ML model and model hyperparameters should have a huge impact on both the accuracy and execution performance.
As for dynamic classifier selection, I think the beginning of the paper is somewhat misleading. What the paper is really selecting is features and batch sizes, instead of classifiers. The selection method is somewhat too simple and doesn't explore more options.
Finally, for the evaluation, it's unclear how much benefit comes from dynamic "classifier selection" and how much is from using features from a few packets in a flow. The comparison between packet-based and flow-based classifiers show AC-DC to be in the middle for accuracy and TTD. That seems a natural consequence of using a few packets in a flow. But how much benefit does dynamic classifier selection contribute to?



General Typos and Minor Issues:
- Page 7, Section 3.4 "a executable"
- Page 7, Section 3.4 "an minimum"


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Review #682B
===========================================================================

Pros: Traffic classification is a popular subject, and I have enjoyed reading your paper.

Cons:
I found the paper very light on the system side. In particular, the paper does not describe the system aspects of AC-DC,
e.g. the software components beyond figure Figure 2. For example, after you select the features and apply the machine learning models, which ML framework do you use (e.g., scikit, pytorch)? if you write everything from scratch, what do you use?
How did you implement your scheduler? what did you use to evaluate the baselines? and so on. These are basic aspects that are expected in a SIGCOMM paper.
The paper evaluates previous works, but does not clearly describe the setup and methodology used. Furthermore, for flow-statistics the referenced work is from 2006, where there are a lot of newer works in this area, especially in traffic classification for anomaly detection. It is therefore not the state of the art that is compared against. The use of a proprietary, closed dataset, makes it even harder to compare the results to any previous works.
The ML performance loss of AC-DC is quite high - 12% drop in F1-score. Indeed you suggest MPR, but the demonstrated MPR is just slightly higher than no MPR, and you don't demonstrate MPR close to packet capture. A sensitivity analysis of MPR is needed. I also have some concerns about the selective use of the ensemble, but this is a common issue with ML.
The features used in the paper are only stateless features, from packet headers. Previous works have relied on more complex features and showed their performance benefits. Here, not only of stateless features are used, also the number of features used is very small compared with other works, especially after the number is trimmed down. There is no analysis of ML performance vs features not scalability vs number of features. Both aspects should be extended and other types of features should be used. The choice to focus on a classification task of "which application is it" helps the authors to reduce the significance of this, but for other tasks classification tasks this is simply not good enough. On top of that, the agility in selection of features is not evaluated or explained in the paper, even though it is hinted as a limitation of previous works.
The paper unnecessarily trashes well established datasets like CAIDA (and others). First, given these datasets are from 2018-2019 they are sufficiently new, especially given you use a dataset from 2018. Second, it is fine to say "I pick the datasets from [9] and [35]" without trashing others. Moreover, I found the dataset that you used quite small compared with the task you had, e.g. for 15K flows/sec, the dataset must have repeated itself every second, reducing the quality of your results.

To much information is in the appendix rather than the main body of the paper. With the exception of table 6, each and every one of the tables in the appendix where required when reading the (main body of the) paper.
In 3.1 you describe the search for memory requirements. How do you expect this to work in a production environment without affecting a running system?
The motivation evaluation in 2.2 does not describe the dataset. You should at least refer the reader to Table 2 (assuming this is what you used).
do you mix all packet traces together? or work with each dataset separately? Please clarify.
What is AC-DC performance (/memory) with 15K flows/second?

General Typos and Minor Issues:
Page 2 - typo - AC-DCremains.
Table 6 - The font is too small.


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


Review #682C
===========================================================================
Pros:
Thank you for submitting your work to SigComm'23. The paper is mostly well-written (very few minor typos are existing though, but that just needs a careful polishing pass on the paper). The problem domain/context was new to me, and the paper did a good job describing the problem well. I learned a lot. I also liked the insight drawn that the bottleneck really ends up being the data preprocessing. The authors make this observation, provide data to support this observation, and then propose a framework that builds a pool of classifiers that differ in characteristics such as accuracy, memory requirements/efficiency, and time they take. The framework focuses on selecting the right set of features for these classifiers, generating and measuring the performance of the classifiers in the pool, and making a selection of the right classifier and batch size for a given scenario/system constraint.

I think the idea of generating a pool of classifiers and selecting one depending on the varying system constraints is cute. The authors have taken a nice systematic approach in this paper:  they took a problem, analyzed it to point to the inefficiencies and propose multiple choices to deal with the problem of dynamically changing execution environments. The proposed AC-DC framework strikes an attractive trades-off: it "retains high performance of packet-capture classifiers while achieving better efficiency, approaching that of flow-statistics classifiers." I really enjoyed reading the way this was explained in the paper :).

Cons:
Figure 5 was great. I suggest using it earlier in the paper to visually motivate what AC-DC aims at achieving.
Do these classifiers need to be retrained? 
How do they react to changes in the data over time? 
How would such retraining get triggered automatically? 
How much overhead would that be given that there are a bunch of classifiers to monitor and retrain? They all have different characteristics (accuracy, especially) which may be an added challenge.
The second question I had was about the online phase of AC-DC that is responsible for making the selection of the classifier and batch size. If I understand correctly, this process stands on the critical path of serving an inference request. It would be great to know the overhead this phase incurs.

General Typos and Minor Issues:
* I didn't get the following sentence (even after reading it multiple times): "To date, we are aware of no existing approach that can achieving high classification performance metrics coupled with the ability to meet the resource demands imposed by the larger networks they must be deployed within". -- page 2, column 1.


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Review #682D
===========================================================================

Pros:
+ The authors proposed the Adaptive Constraint-Driven Classification (AC-DC) framework to efficiently curate a pool of classifiers with different target requirements.
+ An adaptive scheduler is proposed to determine the optimal classifier and batch size to maximize classification performance.
+ The experiment results demonstrate that AC-DC outperforms flow-statistics classifiers by 100% higher in F1-Score and has a 150x higher classification throughput than conventional packet-capture classifiers.


Cons:
Missing comparison to (adaptive) ensemble network traffic identification - See Detailed Info at the end of this document.
For the algorithm, it is not clear why the proposed algorithm can approximate or get the optimal solution.
The experiments can be further enriched with more comparative studies and ablation studies.
How do you determine the optimal batch size? Why is it optimal? There are some conflicts in the paragraph. The authors stated that the batch size is set to the traffic rate at all times. But, it becomes changeable when it comes to the algorithm. However, it is not clear how to calculate and determine the batch size.
The network traffic always changes (not only traffic rates but also its type), and the scheduler may become inappropriate at some time. How does the algorithm adapt to the network changes? Moreover, what do you mean by the described ratio at the end of section 3.4?
There are many types of network features, e.g., statistical-based features, time-series-based features, or etc. It is not clear why the authors’ choice is the best. Please clarify it.
The authors are encouraged to elaborate more details of AC-DC such as the ensemble learning approach and various features. How is ensemble learning implemented? In addition to LightGBM used in the experiments, are there any other models (e.g., decision trees as in [TCPS23]) that can be used in AC-DC? Is AC-DC trying to tackle binary or multi-class classification? The authors are encouraged to present the classes to be predicted. It is encouraged to present different types of features to show the factors that may play crucial roles in AC-DC.
Since there have been many researches exploring ML-based traffic classification (as indicated in [1]), it is suggested to compare with more state-of-the-art solutions.
I recommend to compare the state-of-the-art algorithms in Fig. 6. Moreover, it will be interesting to measure F1-score under different traffic rates, batch sizes, and memory availability.
The experiments can be further enriched with more comparative studies and ablation studies. The authors are encouraged to include more ensemble learning-based baselines. The authors are encouraged to conduct ablation studies of various features to see their importance. More metrics such as accuracy, precision, and recall can be evaluated to achieve more comprehensive insights. The authors are encouraged to conduct case studies with concrete examples.


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


Review #682E
===========================================================================


Pros:
This paper addresses a significant problem in packet classification. It is well-written and easy to follow. I have a few comments and suggestions to improve this paper further.

Cons:

Need further rationales and analysis for the motivational experiments.
 I don’t understand why TTD is too high in pre-processing the packet-capture method, although this baseline uses only the first three packets of each flow. What are the operations that took ~855 times more than simple feature calculation in flow statistics?
The authors varied the traffic rate from 10 to 7,000 flows/second. Any rationales for this range? I am not sure whether this range is practical or an extreme case.
The authors mentioned that “we follow the assumption that a new instance of the classifier is initiated every second to classify all traffic received in the previous second.” Is this a realistic assumption? What are alternatives?
The contribution of the proposed methodology (AC-DC) is not clear. If I understand correctly, it selects a set of static features and finds the best model combination and batch size that meets the memory and TTD requirements. It is difficult to find technical challenges in developing such a method. The method is too straightforward, resulting in expected performance and limitations. It is hard to tell if the method is a simple engineering effort or a novel idea. The authors should highlight the challenges and the novelty of the technique.
The data size used for evaluation is too small. The authors used three datasets (video streaming, conferencing, and social media), all with less than 10K flows. However, the flow rate of the evaluation ranged from 100 to 15,000. This means that in the extreme case (15,000), the data size is shorter than one second, too short for a proper evaluation. I believe larger datasets exist, such as the VPN-nonVPN dataset (https://www.unb.ca/cic/datasets/vpn.html) used in the packet-capture baseline [33], which contains a few million samples.
The impact of the result is questionable. As shown in Table 3, AC-DC showed higher accuracy and memory usage than the flow-statistics baseline, while it showed lower accuracy and memory usage than the packet-capture baseline. It is difficult to say that AC-DC outperforms existing methods because it is in the middle of the two baselines. For instance, with the advance of parallel computing and the ML cores, would AC-DC still be more beneficial than the packet-capture baseline that shows higher accuracy?

General Typos and Minor Issues:
Typo: Section 1, p2, last paragraph: AC-DCremians -> AC-DC remains




### References

The authors have clearly claimed that conventional flow-statistics-based and packet-capture-based methods failed to address the trade-off between effectiveness and efficiency in network traffic identification. However, there are several adaptive/ensemble network traffic (intrusion) identification to be compared for clarification of contributions. The authors are encouraged to compare with more (adaptive/ensemble) network traffic (intrusion) identification to show the superiority of AC-DC.

* Online incremental learning, which is employed in [IoTJ23-1], may also be a suitable solution to address the trade-off between effectiveness and efficiency, especially when dealing with incoming traffic data.

[IoTJ23-1] E. Gyamfi and A. D. Jurcut, "Novel Online Network Intrusion Detection System for Industrial IoT Based on OI-SVDD and AS-ELM," in IEEE Internet of Things Journal, vol. 10, no. 5, pp. 3827-3839, 1 March1, 2023.

* In addition to ensemble learning, collaborative learning may also be helpful by leveraging multiple models trained in similar environments and detecting intrusions in a collaborative manner as in [IoTJ23-2].

[IoTJ23-2] Z. Ma, L. Liu, W. Meng, X. Luo, L. Wang and W. Li, "ADCL: Towards An Adaptive Network Intrusion Detection System Using Collaborative Learning in IoT Networks," in IEEE Internet of Things Journal, 2023.

* Deep reinforcement learning may also be helpful to strike a better balance between effectiveness and efficiency with a dynamic intrusion response solution as in [TNSM22].

[TNSM22] T. V. Phan and T. Bauschert, "DeepAir: Deep Reinforcement Learning for Adaptive Intrusion Response in Software-Defined Networks," in IEEE Transactions on Network and Service Management, vol. 19, no. 3, pp. 2207-2218, Sept. 2022

* The authors are encouraged to consider class imbalance as in [Neurocomputing19], which also employs ensemble learning and may be a suitable baseline for AC-DC.

[Neurocomputing19] Gómez, Santiago Egea, et al. "Exploratory study on class imbalance and solutions for network traffic classification." Neurocomputing 343 (2019): 100-119.

[TCPS23] Jarul Mehta, Guillaume Richard, Loren Lugosch, Derek Yu, and Brett H. Meyer. 2023. DT-DS: CAN Intrusion Detection with Decision Tree Ensembles. ACM Trans. Cyber-Phys. Syst. 7, 1, Article 4 (January 2023), 27 pages.

[1] F. Pacheco, E. Exposito, M. Gineste, C. Baudoin and J. Aguilar, "Towards the Deployment of Machine Learning Solutions in Network Traffic Classification: A Systematic Survey," in IEEE Communications Surveys & Tutorials, vol. 21, no. 2, pp. 1988-2014, Secondquarter 2019.

- Address data size for evaluation.

Generally:

- Move important content from appendix to the main body.
- Clarify the use of packet traces: Specify whether all packet traces are mixed together or used separately.
- Reorganize visual elements.
- Highlight the novelty and challenges of AC-DC: The paper needs to better articulate the challenges addressed and the novelty introduced by AC-DC to establish its contributions beyond an engineering effort.
- Clarify the impact of AC-DC: The benefits and impact of AC-DC need to be clearly stated. Current results place AC-DC in the middle of two baselines which makes it difficult to gauge its performance.
