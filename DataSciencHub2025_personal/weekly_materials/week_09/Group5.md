# Spatial analysis using the Google Earth Engine_

## Has forest cover change occurred across protected areas?
## Data Science Hack-a-thon

### Google Earth Engine link
https://code.earthengine.google.com/


Login to find the challenge script for your group.

Link to the GEE scripts: 

- Group 1: [https://code.earthengine.google.com/ac3ddea0c65a560931f17bd9bb178136](https://code.earthengine.google.com/dccd370a77c76697c72e154966af36ab)
- Group 2: [https://code.earthengine.google.com/d34419a235b1e84f802c7007210ba170](https://code.earthengine.google.com/64cbd05e6727618e1f570d35e39f46a8)
- Group 3: https://code.earthengine.google.com/75f0b6804457fa8c00c62f67b40ea5d9
- Group 4: [https://code.earthengine.google.com/3f911d57652eb8ae74af9fb5f4a4c34d](https://code.earthengine.google.com/0aa119eaa5c359a35fb841fecf4ba929)
- Group 5: [https://code.earthengine.google.com/8e3b174404344696b6a5c1d1c2625a22](https://code.earthengine.google.com/13bb4502b7be4b12cc6ee0751d63c9b2)
- Group 6: [https://code.earthengine.google.com/13bb4502b7be4b12cc6ee0751d63c9b2](https://code.earthengine.google.com/49f49302ffd64862a86202b3410d0961)
- Group 7: https://code.earthengine.google.com/6262f6238b491f9ca8a1340f22fd0f31

# Overarching goal
_*Investigate forest cover change across protected areas.*_


# Challenge aims
- Map forest cover change from the Hansen et al. Database for your group's protected area as well for the larger region surrounding the protected area
- Create a figure in R visualising the amounts of forest cover change over time
- Report the state of forests in your group's protected area in a Markdown document


_Use this document as a template to fill in as you progress through the challenge._

# Title

Forest cover change in Białowieża National Park


# Authors

Charlotte Ault,
Rowan McAllister,
Star Barbour,
Katy Scott


# Research question
__How much forest cover loss and gain has occurred in Białowieża National Park?__


# Introduction

_*Introduce the reader to your park and research questions that you are testing during this challenge in 200 words or fewer. You can include a few references if you would like.*_


The National Park is situated in the north-east part of Poland, in podlaskie voivodeship. The Park covers the central part of Białowieża Forest. The Park covers the area of 10 517,27 ha, which constitutes 1/6 of the Polish part of Białowieża Forest. 6059,27 ha is under strict protection, 4104,63 ha is under active protection, and landscape protection covers the area of 353,37 ha. 

There has been a protection zone created around the Park which covers the state commercial forest having an area of 3224,26 ha. This national reserve is exhibiting a major problem in capony reduction, with 26% of the entire Polish part of BF has been logged. This will have a serious impact on the natural dynamics in this area, making it crucial to employ conservation efforts.

This report will discuss how much forest cover loss and gain has occurred in Białowieża National Park through mapping simulations on Googloe Earth Engine. This allows us to have a clear view of the change in forest canopy cover, allowing conservation efforts to be planned and implimented.

# Workflow

<img width="1362" height="824" alt="Workflow" src="https://github.com/user-attachments/assets/69cd1434-8de9-4250-b273-abdd1e7af9a7" />


# Specific hypotheses and predictions

_*What do you know about this protected area?  What sort of factors could influence forest cover change in this part of the world?*_

Significant logging in 2017 due to the spruce dark beetle attacking the Norway spruce trees has had a detrimental effect on the forest cover in the national park. Norway spruce trees are also very sensitive to drought, which is becoming more prevalent due to climate change. We expect the pressure of drought to be increasingly weakening the forest canopy, in turn reducing the forest cover in the national park. 


# Methods

_*Describe your methods in brief including all of the datasets that you used with appropriate crediting/referencing/copyright for the datasets.*_

We used Google Earth Engine to create a csv file with the gains and losses of tree coverage from 2000-2016 in Białowieża National Park. To do this, we utilized the Hansen Global Forest Change and WDPA data sources (citations included below).

Hansen, M. C., P. V. Potapov, R. Moore, M. Hancher, S. A. Turubanova, A. Tyukavina, D. Thau, S. V. Stehman, S. J. Goetz, T. R. Loveland, A. Kommareddy, A. Egorov, L. Chini, C. O. Justice, and J. R. G. Townshend. "High-Resolution Global Maps of 21st-Century Forest Cover Change." Science 342 (15 November): 850-53. 10.1126/science.1244693 Data available on-line at: https://glad.earthengine.app/view/global-forest-change.

UNEP-WCMC and IUCN (year), Protected Planet: The World Database on Protected Areas (WDPA) [On-line], [insert month/year of the version used], Cambridge, UK: UNEP-WCMC and IUCN Available at: www.protectedplanet.net.

# Data vis and summary methods

_*Describe your data visualisation, any mathematical summaries and/or any statistical methods that you used in brief. Include any relevant R code snippets.*_

```r
Your code
```

# 1. Maps of forest cover change for your protected area

_*Describe your results using appropriate scientific writing. Include maps of your protected area with informative captions.*_

_*Your maps*_
![alt text](https://github.com/lewisoscar4481/GEE-Hack-a-thon/blob/788d64ddaa8cac6a7f7834ff259e378dba144f3e/Images/Screenshot%202025-11-13%20at%2014.32.38.png)

# 2. Visualisation of the amount of forest cover loss and gain for your protected area

<img width="2100" height="1500" alt="forest_barplot" src="https://github.com/user-attachments/assets/a00588cf-c6bc-435d-a616-b3d7464dcb83" />





# 3. How do your results compare with your predictions? What do you think might explain the patterns you found?

Our prediction was that there would be a loss in forest cover change, and there was.

# 4. What other datasets, available within the GEE, could you use to test the potential drivers of forest cover change in your group's protected area that you identified in point #3. ?

_*Browse through the GEE Data catalogue and provide a link to your chosen dataset with a brief statement about why you chose it. Note you don't need to do analyses with this new dataset, you are just making a suggestion for future studies.*_

__*Link and description of your chosen dataset*__
We could use the Google DeepMind Global Drivers of Forest Loss dataset (Sims, M., Stanimirova, R., Raichuk, A., Neumann, M., Richter, J., Follett, F., MacCarthy, J., Lister, K., Randle, C., Sloat, L., Esipova, E., Jupiter, J., Stanton, C., Morris, D., Slay, C. M., Purves, D., and Harris, N. (2025). Global drivers of forest loss at 1 km resolution. Environmental Research Letters. doi:10.1088/1748-9326/add606). This dataset includes a multitude of factors that could lead to forest loss such as agriculture and wildfire. Mapping this dataset with our existing plots could show what is causing the deforestation. 

_*BONUS! If you have the time, for some bonus recognition, map your chosen dataset in the GEE and include a visualisation of the dataset for your protected area (screencap from GEE).*_


# 5. What research question and hypotheses would you test with those additional datasets in your proposed future research and why does that research matter for the park management?

Using this information, here are some of our proposed future research questions.

- How much of this loss is due to logging?
- How much of this loss is due to climate change?
- How much of this loss is due to land use change?
- What were the contributing factors to gains in forest coverage?

We believe these questions could aid future conservation efforts and plans that are targeted to this specific area.


# Conclusions

Forest cover change in  Białowieża National Park has **significantly declined**. While there is some gain, it is incomparable to the amount of loss. As mentioned in our introduction and predictions, this is probably mostly due to the combined effects of logging and climate change.

