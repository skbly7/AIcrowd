Accurate skip prediction can enable us to avoid recommending a potential track to the user, based on the user's immediately preceding interactions. At a given moment in time, it is therefore most important to predict if the next immediate track is going to be skipped, but it would also be useful to predict if the tracks further into the session will be skipped. This motivates our use of Mean Average Accuracy as the primary metric for the challenge, with the average accuracy defined by

$$
\begin{align*}
AA = \frac{\sum_{i=1}^T{A(i)L(i)}}{T}
\end{align*}
$$

where :

* $$ T $$ is the number of tracks to be predicted for the given session
* $$ A(i) $$ is the accuracy at position $$i$$ of the sequence
* $$ L(i) $$ is the boolean indicator for if the $$i$$'th prediction was correct.

We will use the accuracy at predicting the first interaction in the second half of the session as a tie breaking secondary metric.