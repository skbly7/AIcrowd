> Update 08 Jan 2019: The submission system is now live on [ EasyChair ](https://easychair.org/conferences/?conf=wsdmcup2019ssspc){:target='_blank'}. We hope to see many of you submit reports on your work for this challenge.
{: .update}

> Update 07 Jan 2019: The final results are now available. We will be contacting the teams to confirm that their code is open sourced and can be verified, but a provisional congratulations to the winning teams, and thank you all for participating in this challenge. We look forward to reading and hearing about your insights.
{: .update}

> Update 04 Jan 2019: Good luck to all contestants in the final hours of the challenge! Once the submission period has concluded we will begin the final leaderboard evaluations. Additionally, we are in the process of finalizing the paper submission system for the WSDM Cup workshop, the deadline will be January 11, 2019. In the meantime, see the Call for Papers section here on the challenge overview page for information. Please note that submitting a paper is mandatory in order to be considered for the winning leaderboard positions, and in order to be eligible for the prizes.
{: .update}

> Update 12 Dec 2018: We would like to make several announcements: (1) We are happy to share that Google have kindly offered to sponsor coupons for google cloud compute resources for participants of this challenge. Please see the ‘Google Sponsored Computational Resources’ section of the overview page for further details. (2) We have released the call for papers for the WSDM Cup Workshop day. Please see the ‘Rules’ and ‘Call for Papers’ sections of the overview page for further details. (3) We are now providing the training set split into 10 files to make it easier for participants with slow connections to download the training set. Please see the Training_Set_Split_Download.txt file under the Dataset tab for the download links. (4) There was some ambiguity in the description of the challenge metric which has now been clarified, see the 'Evaluation' section of the overview page for further details. Please note that the metric is unchanged we have simply clarified the terminology.
{: .update}

> Update 20 Nov 2018: Unfortunately we have had to make some changes to the challenge dataset. More specifically, we have had to remove some features from the track features table (the updated Dataset Description file outlines the new track features schema). Please note that the other parts of the dataset all remain unchanged, except the track features table in the mini version of the dataset which was changed correspondingly. We apologize for any inconvenience caused by this change. If your work on the challenge is affected, we would appreciate if you email us at [ wsdm-cup-2019@spotify.com ](wsdm-cup-2019@spotify.com){:target='_blank'} so that we can better understand any potential impact on participants.
{: .update}

Spotify is an online music streaming service with over 190 million active users interacting with a library of over 40 million tracks.
{: .lead #introduction}
A central challenge for Spotify is to recommend the right music to each user. While there is a large related body of work on recommender systems, there is very little work, or data, describing how users sequentially interact with the streamed content they are presented with. In particular within music, the question of if, and when, a user skips a track is an important implicit feedback signal.

We release this dataset and challenge in the hope of spurring research on this important and understudied problem in streaming. Our challenge focuses on the task of session-based sequential skip prediction,  i.e. predicting whether users will skip tracks, given their immediately preceding interactions in their listening session.

The organization of this challenge is a joint effort of [ Spotify ](https://www.spotify.com){:target='_blank'}, [ WSDM ](http://www.wsdm-conference.org/2019/){:target='_blank'}, and [ CrowdAI ](https://www.crowdai.org/){:target='_blank'}.

## Dataset

The public part of the dataset consists of roughly 130 million listening sessions with associated user interactions on the Spotify service. In addition to the public part of the dataset, approximately 30 million listening sessions are used for the challenge leaderboard. For these leaderboard sessions the participant is provided all the user interaction features for the first half of the session, but only the track id's for the second half. In total, users interacted with almost 4 million tracks during these sessions, and the dataset includes acoustic features and metadata for all of these tracks.

If you use this dataset in an academic publication, please cite the following paper:

@inproceedings{brost2019music,
  title={The Music Streaming Sessions Dataset},
  author={Brost, Brian and Mehrotra, Rishabh and Jehan, Tristan},
  booktitle={Proceedings of the 2019 Web Conference},
  year={2019},
  organization={ACM}
}

## Challenge

The task is to predict whether individual tracks encountered in a listening session will be skipped by a particular user. In order to do this, complete information about the first half of a user’s listening session is provided, while the prediction is to be carried out on the second half. Participants have access to metadata, as well as acoustic descriptors, for all the tracks encountered in listening sessions.

The output of a prediction is a binary variable for each track in the second half of the session indicating if it was skipped or not, with a 1 indicating that the track skipped, and a 0 indicating that the track was not skipped. For this challenge we use the skip_2 field of the session logs as our ground truth.

There will be a workshop at WSDM where selected or top performing teams will be invited to present their work on this challenge. The paper submission deadline will be January 11, 2019, and the workshop will be held on February 15, 2019, as part of WSDM in Melbourne, Australia

## How to generate submissions

The test set sessions are always split between two files. Each session is partly contained in a prehistory file, and a corresponding input file. The full interaction feature set  for the first half of the session is contained in the prehistory file, and the track id's for which you need to make a prediction are contained in the input file. For each test set session a row of 1's and 0's of the same length as the input part of the session must then be generated. Sample submissions are contained in the Sample_Submissions.tar.gz file under the Dataset tab, and code for generating a random submission is contained in the [ Starter Kit ](https://github.com/crowdAI/skip-prediction-challenge-starter-kit){:target='_blank'}.

