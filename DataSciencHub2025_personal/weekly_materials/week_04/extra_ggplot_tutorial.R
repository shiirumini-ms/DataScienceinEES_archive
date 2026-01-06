#### A little tutorial on ggplot
### Written by Hannah Wauchope, Jan 2022, hannah.wauchope@gmail.com
### Migrated to tidyverse Oct 2024

#This tutorial is an introduction to ggplot, that starts basic and then starts to introduce increasingly fun and complex ways of doing things!
#It's based on some simple data about penguins. Use this as a reference to then explore and build your own exciting plots! 

#### Set up ####
library(ggplot2)
library(tidyverse)

#We're gonna use a dataset on penguins for this tutorial install from Allison Horst
remotes::install_github("allisonhorst/palmerpenguins")
library(palmerpenguins)

#Let's take a look
glimpse(penguins)
#This is some body size measurements of three penguin species at 3 islands in Antarctica. We also have data on their sex and the year of the measurements. 

#You'll note when you look at this data that it's in "long" format - there's a column for every "thing" we want to measure, and no categories are spread across rows. 
#This is how data needs to be for ggplot, not in wide format.

#For example, you could have a wide format dataframe that looked like this:
penguins %>% drop_na() %>% group_by(island, species) %>% summarise(MeanFlipperLength=mean(flipper_length_mm)) %>% pivot_wider(names_from=species, values_from=MeanFlipperLength)#This shows mean flipper length, with islands in the rows, and penguin species in the columns. 
#This is wide format, and no good. Instead, we need to make it long, with a column for islands, a column for species, and a column for flipper length
#Thankfully we're already ready to go

#Just one thing - there's some rows with NAs. Let's get rid of them. 
penguins <- penguins %>% drop_na()

#Better. Right, let's begin!

#### The Basics - building a plot ####
#Let's say we want to see if there's a correlation between bill and flipper length

#Let's set up a plot. We'll use the ggplot command, 
#and tell it we're plotting with the penguin data, and that we want an axis for bill length and one for flipper length
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm))

#Great, that gives us the axes, but nothing has been plotted. 
#Let's add a point for each penguin individual
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm))+
  geom_point() #Note that we don't put anything in the brackets here. Things will come later!
#You'll get a warning saying "rows removed". This is just cos there's a couple of NAs in the data

#Ok, cool. Does flipper length vary by species?
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_point()

#Hmm, doesn't seem so useful to use points for a categorical variable. Let's get ggplot to summarise then into a boxplot for us first. 
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot()

#Or we could do a violin plot
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_violin()

#It's often bad practice to just give a box/violin plot without giving an indication of the sample size in each group. Let's plot points *and* boxplot
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_jitter()+ #Geom_jitter is similar to geom point, but it just jitters the points around a bit so you can see them more easily (if you do ?geom_jitter you can specify the horizontal and vertical jitter)
  geom_boxplot()
  
#Hmm, we can't see the points very well. Let's switch the order of boxplot and points put them on top instead. 
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot()+
  geom_jitter()

#Great! So each of these things we just plotted (point, boxplot, violin, jitter) are called layers. You can add as many as you like to a plot

##A few other basic things:

#If we want to add or adjust axis labels, we use the labs command:
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot()+
  geom_jitter()+
  labs(x="Penguin Species", y="Flipper Length")

#If you want to change the names of the categorical variables 
#(e.g. let's say we wanted to give the scientific names for the penguins rather than the common names)
#it's best to do that in the dataframe, rather than in ggplot

penguins$species <- recode_factor(penguins$species, "Adelie" = "Pygoscelis adeliae", "Chinstrap" = "Pygoscelis antarcticus", "Gentoo" = "Pygoscelis papua")

ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot()+
  geom_jitter()+
  labs(x="Penguin Species", y="Flipper Length", title="Flipper length of Antarctic penguin species")

#### The Basics - adjusting visuals ####

### Colours ###

#It's still kinda hard to see the boxplots. How about we make the points semi-transparent
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot()+
  geom_jitter(alpha=0.2) #alpha = 1

#Maybe it's better to make the points and boxplots different colours
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot(fill="skyblue2", colour="skyblue3")+
  geom_jitter(alpha=0.5, colour="forestgreen")

#How pretty (nb... this is terrible for a professional graph, you should really only use colours when necessary, but we're having fun)

### Axes values ###

#It seems a bit uncessary to have y axis ticks for every 10mm, let's reduce it by setting our own 'breaks'
#We add a line with details about the y scale: "scale_y_continuous"
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot(fill="skyblue2", colour="skyblue3")+
  geom_jitter(alpha=0.5, colour="forestgreen")+
  scale_y_continuous(breaks=c(160, 180, 200, 220, 240)) #You can also use this scale line to do other things, e.g.set an upper and lower limit for what points you want to show - try adding ", limits=c(180,200)")

#use scale_x_continuous for the x axis, and scale_y_discrete/scale_x_discrete for categorical axes

### Themes ###

#The lines behind the graph are kinda ugly, how do we fix that?

#For visuals not associated with 'layers' (layers = e.g. box plot, points), or with actual axis values, we use theme. 
#ggplot has some built in themes you can use

#E.g. theme classic just has x and y lines, nothing else
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot(fill="skyblue2", colour="skyblue3")+
  geom_jitter(alpha=0.5, colour="forestgreen")+
  theme_classic() 

#Theme minimal has only grid lines and no axis lines (I don't like this one, it's not very fashionable right now)
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot(fill="skyblue2", colour="skyblue3")+
  geom_jitter(alpha=0.5, colour="forestgreen")+
  theme_minimal() 

#There are packages that you can download to get all sorts of themes, e.g. "ggthemes", "ggthemr" (See more here https://rfortherestofus.com/2019/08/themes-to-improve-your-ggplot-figures/)

#However, sometimes you want to just control it yourself, to make it look exactly how you want. In that case, just use "theme" and do it yourself.
#The theme call has its own little language, with a variety of different 'elements'. 
#e.g. you need to tell theme if you're talking about a line: element_line(), some text: element_text(), a rectangle: element_rect(), or if you want nothing at all: element_blank()
#Like so:

#Let's say we don't want any grid lines. The grid lines are part of the panel (the word ggplot uses to refer to the data part of the plot, not the part with labels etc)
#We want to make them blank, so we use element_blank
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot(fill="skyblue2", colour="skyblue3")+
  geom_jitter(alpha=0.5, colour="forestgreen")+
  theme(panel.grid = element_blank()) #element_blank just means "don't show that thing"

#I don't love that the panel background is grey. I would rather it were pink. Let's do it. 
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot(fill="skyblue2", colour="skyblue3")+
  geom_jitter(alpha=0.5, colour="forestgreen")+
  theme(panel.grid = element_blank(),
        panel.background = element_rect(fill="hotpink")) #The panel background is a rectangle, so we use the 'element_rect' call

#There aren't any axis lines though, that's annoying, let's fix it. And make really fat axis lines.
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot(fill="skyblue2", colour="skyblue3")+
  geom_jitter(alpha=0.5, colour="forestgreen")+
  theme(panel.grid = element_blank(),
        panel.background = element_rect(fill="hotpink"),
        axis.line = element_line(colour="black", size=2)) #Axis lines are.. lines, so we use element_line

#Now, I would rather the axis labels were HUGE and the axis text *tiny*. Let's do it. 
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot(fill="skyblue2", colour="skyblue3")+
  geom_jitter(alpha=0.5, colour="forestgreen")+
  theme(panel.grid = element_blank(),
        panel.background = element_rect(fill="hotpink"),
        axis.line = element_line(colour="black"),
        axis.title = element_text(size = 20), #We use element_text because it's text. You can also call axis.title.x to adjust only the x axis label (ditto for y)
        axis.text = element_text(size = 6)) #We use element_text because it's text. You can also call axis.text.x to adjust only the x axis text (ditto for y)

#Finally, I find it really helpful to set the aspect ratio of the graph so it looks how I want. I want this graph to be wider than it is tall, so I'll set the aspect ratio
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot(fill="skyblue2", colour="skyblue3")+
  geom_jitter(alpha=0.5, colour="forestgreen")+
  theme(panel.grid = element_blank(),
        panel.background = element_rect(fill="hotpink"),
        axis.line = element_line(colour="black"),
        axis.title = element_text(size=20), 
        axis.text = element_text(size = 6),
        aspect.ratio=0.5) #1 will make the plot square, <1 will make it short and fat, >1 tall and skinny.

#Ok wonderful. We've made the ugliest graph in all existence. There's so much more you can do with theme, just google what you need!

#### The Basics - bar graphs ####

#A quick section on bar graphs as they're a slightly different case. 
#Often we're using bar graphs as a summary, e.g. we might want to know the number of penguins in our dataset.
#Either you can calculate the values of the bar graphs and tell ggplot to use the exact values you give it
#or you can ask ggplot to do the summary for you. 

#For example, let's get ggplot to count how many individuals per species
ggplot(data=penguins, aes(x=species))+ #We're not going to give a y axis value here, as we want r to calculate it
  geom_bar(stat = "count") #We want it to count the number of rows for each species, so we say stat = count

#What about if we want to know the mean flipper length per species
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+ #Now we're going to add a y axis value
  geom_bar(stat = "summary", fun="mean") #We want ggplot to calculate the mean value - we say we want a summary statistic (stat=summary), and that that statistic is the mean (fun=mean)

#We can get even more funky, and do stacked bar plots using 'fill'
#For instance, let's get number of individuals per species, coloured by island
ggplot(data=penguins, aes(x=species, fill=island))+ #Let's count the number of penguins, but split it by island. 
  geom_bar(stat = "count")

#Want them to be next to each other rather than stacked? Add "position = 'dodge'"
ggplot(data=penguins, aes(x=species, fill=island))+ #Let's count the number of penguins, but split it by island. 
  geom_bar(stat = "count", position = "dodge")

#Of course, sometimes you'd rather just calculate the values yourself and feed it to ggplot
#For instance, let's calculate mean and sd of body mass ourselves per species
FlipMean <- penguins %>% group_by(species) %>% summarise(BodyMassMean = mean(body_mass_g), BodyMassSd = sd(body_mass_g))

ggplot(data=FlipMean, aes(x=species, y=BodyMassMean))+ 
  geom_bar(stat = "identity") #Stat identity says "just use the values as given"

#It would be useful to have error bars for this!
ggplot(data=FlipMean, aes(x=species, y=BodyMassMean))+
  geom_bar(stat = "identity")+
  geom_errorbar(aes(ymax=(BodyMassMean + BodyMassSd), ymin=(BodyMassMean - BodyMassSd))) #For error bars we specify the max and min values. You'll see that it's smart enough to know there are different values for each species

#### More complex graphs - colours/shapes as factors ####

#We've made some lovely visuals and added some crazy colours. 
#But what about if we want to use colours to communicate information, rather than just for visuals?

#Let's go back to our simple point graph
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm))+
  geom_point()

#It would  be interesting to know if this relationship varies by species. Let's colour the points by species
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm, colour=species))+ #Note that depending on what layer you're using, you may want to use colour, or fill, or both here
  geom_point()

#Interesting! What if we wanted to change the colours?
#Kind of like how before when we wanted to adjust x and y axes we used the "scale_y_" line
#Now we use a "scale_colour" line, to adjust the colour scale. If we want to specify the colours ourselves, we use "scale_colour_manual"
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm, colour=species))+ 
  geom_point()+
  scale_colour_manual(values=c("Pygoscelis adeliae" = "yellow", "Pygoscelis antarcticus" = "orange","Pygoscelis papua" = "red")) #You can specify which colour goes with which species, as we've done here, or just list the colours and the order is the same as the order of the levels in your factor (you can see this by running levels(penguins$species) and change it by running e.g. levels(penguins$species) <- c("Pygoscelis antarcticus", "Pygoscelis papua", "Pygoscelis adeliae")

#there are TONNES of colour packages to give you colour options. My two favourites are viridis and RColorBrewer

library(viridis) 
library(RColorBrewer)

#Eg for viridis we now use "scale_colour_viridis" (i.e. the viridis colour scale)
#Viridis needs to know if you're using a categorical variable (like Species here), by specifying that its a discrete (vs continuous) variable
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm, colour=species))+ 
  geom_point()+
  scale_colour_viridis(discrete=TRUE) #The order of the colours here is the same as the order of the levels in your factor (you can see this by running levels(penguins$species) and change it by running e.g. levels(penguins$species) <- c("Pygoscelis antarcticus", "Pygoscelis papua", "Pygoscelis adeliae")

#viridis has a few different colour scales (type vignette("intro-to-viridis") and scroll down to see), you can specify which one you want with e.g, scale_colour_viridis(option="inferno")
#They're all colorblind friendly which is great

#For RColorBrewer you need to choose your color palette. See them all here:
display.brewer.all(colorblindFriendly = TRUE) #I like to only over use colorblind friendly palettes, so set this to true

#Then choose for your plot
#Note now we're using "scale_colour_brewer" for RColorBrewer
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm, colour=species))+ 
  geom_point()+
  scale_colour_brewer(palette="Set2") #The order of the colours here is the same as the order of the levels in your factor (you can see this by running levels(iris$Species) and change it by running e.g. levels(iris$Species) <- c("versicolor", "virginica", "setosa")

###You can apply all these same principles to shape instead, e.g.
#See the bototm of pg 2 of the ggplot2 cheatsheet for all the shape types. Each type corresponds to a number
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm, shape=species))+ 
  geom_point()+
  scale_shape_manual(values=c(2, 4, 15))

#Or do both!
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm, colour=species, shape=species))+ 
  geom_point()+
  scale_shape_manual(values=c(2, 4, 15))+
  scale_colour_viridis(discrete=TRUE)

### So far all these colours have been with discrete colour groups. What about a continuous color scale?
#Let's see what happens if we colour the points by bodymass

#Let's colour points by petal width
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm, colour=body_mass_g))+ #Note that depending on what layer you're using, you may want to use colour, or fill, or both here
  geom_point()+
  scale_colour_viridis()

#So that's a continuous color scale. How do we change what the colours are?
#For viridis, just do as above but remove the "discrete=TRUE"
#For RColorBrewer, use the line "scale_colour_distiller" and specify your palette as above. 
#If you want to define your own colour scale, you can define the start and end colours
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm, colour=body_mass_g))+ 
  geom_point()+
  scale_colour_gradient(low="blue", high="green")

#### More complex graphs - multiple panels ####
#Sometimes you'd want to make more than one graph at once. There are two general categories for this: 
#either you want the same plot type, just with different data, or you want different types of plots. 
#The same plot with different types of data could be, e.g. a graph of flipper vs beak length, with one for each species
#Different plots could be wanting to have a boxplot, a scatter plot and a bargraph all arranged together.

#To do the former (same plot with different types of data), you need facets:

#Let's take our plot of bill vs flipper length, coloured by species
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm, colour=species))+
  geom_point()

#Now, instead of colour, let's split it into facets
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm))+ 
  geom_point()+
  facet_wrap(~species) #This has put them in a row, you could specify ncol=1 to make then stack into one column

#You can go further and split by two factors. Let's say you had both species and location that you wanted to split by
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm))+ 
  geom_point()+
  facet_grid(island~species) #Note this says facet_grid rather than facet_wrap, facet_grid plots one factor as columns, the other as rows (in this case species vs. island)

#You can adjust all sorts about how the facets look using theme. Each facet is called a "strip" in theme, just to be confusing. E.g. 
ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm))+ 
  geom_point()+
  facet_grid(island~species)+
  theme(strip.background = element_blank(), #Remove the grey background from the strip labels
        strip.text = element_text(colour="blue", hjust=0)) #Make the labels blue, and left align (hjust stands for horizontal adjustment, use 0 for fully left aligned, 1 for fully right aligned, or whatever in between)

#What about the other type of panels - where you want different types of graphs arranged together?

#This requires some more packages. There are two main types that people use: cowplot and gridExtra 
library(cowplot)
library(gridExtra)

#Their syntax is fairly similar, and there are a lot of good online resources. 
#CowPlot is easier, gridExtra you more control. 

#### Let's start with cowplot

#First, let's make 3 plots that we then want to arrange together

#Scatter plot of bill length vs flipper length
BillVsFlipper <- ggplot(data=penguins, aes(x=bill_length_mm, y=flipper_length_mm))+ 
  geom_point()+
  theme_classic()

#Boxplot of species vs flipper length
SpeciesVsFlipper <- ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot()+
  theme_classic()

#Boxplot of species vs bill length
SpeciesVsBill <- ggplot(data=penguins, aes(x=species, y=bill_length_mm))+
  geom_boxplot()+
  theme_classic()

#Now put em together!
plot_grid(BillVsFlipper, SpeciesVsFlipper, SpeciesVsBill, nrow=3)

#It would be helpful to label each panel, let's do that
plot_grid(BillVsFlipper, SpeciesVsFlipper, SpeciesVsBill, nrow=3, labels=c("a", "b", "c"))

#There's lots of ways you can play around with how the plots are aligned, and how you want to labels to look. see ?plot_grid for a useful overview. 

### GridExtra
#Now gridExtra let's us get pretty funky with how we do things. 
#Let's say we want the scatter plot bigger, and the two other plots stacked next to it.

#First we create a template grid. Imagine a block of grid cells, and that you're colouring in where you want the plots to be.
#This is a little hard to explain with text, so ima draw it:

#Ignore the following code unless you're interested, just look at what it plots
d <- data.frame(x1=c(1,4,4), x2=c(4,6,6), y1=c(1,2.5,1), y2=c(4,4,2.5), PlotName=c("Plot 1", "Plot 2","Plot 3"))
ggplot() + 
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2, fill=PlotName), alpha=0.5, color="black") +
  geom_text(data=d, aes(x=x1+0.4, y=y2-0.2, label=PlotName), size=4)+
  geom_line(aes(y=2.5, x=c(1,6)))+
  theme_void()+
  theme(aspect.ratio=0.7)

#We see a grid of four rectangles of different sizes. Plot 1 uses the two rectangles on the left, Plot 2 the upper right rectangle, Plot 3 the lower right rectangle. 
#This is how we want our plots arranged. 

#So first, we're going to specify this layout:
GridLayout <- rbind(c(1,2), c(1,3)) #Row 1 of the rectangles is plot 1, plot 2; and row 2 is plot 1, plot 3
GridLayout #You can see that the labels are arranged like in the diagram

#Next we'll list the plots in order of their numbers
GridPlots <- list(BillVsFlipper, SpeciesVsFlipper, SpeciesVsBill)

#Now put it together. We specify the 'grobs' (i.e. the plots), the layout grid
#And then we say how wide we want the grid cells, and how high we want them. We want the first column to be wider than the second, but for the rows to be the same height. 
ComboPlot <- grid.arrange(grobs = GridPlots, layout_matrix = GridLayout, 
                          widths = unit(c(70, 35), c("mm")), 
                          heights=unit(c(35,35), c("mm")))

#Magic! You can get as funky as you like with this, just sketch our your plots on a grid and then set your grid layout accordingly
#You can see here I've done a bad job of sizing on this because the species names are overlapping in the boxplots. I could adjust the sizing
#Or, I could make the species names go on a 45degree angle. To do this I would add a line saying "axis.text.x = element_text(angle=45)" to theme

#### Saving graphs ####

#So you've made all these graphs. Time to export them.

#Let's save our ugly as hell graph

#Give the plot a name
UglyPlot <- ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot(fill="skyblue2", colour="skyblue3")+
  geom_jitter(alpha=0.5, colour="forestgreen")+
  theme(panel.grid = element_blank(),
        panel.background = element_rect(fill="hotpink"),
        axis.line = element_line(colour="black"),
        axis.title = element_text(size=20), 
        axis.text = element_text(size = 6),
        aspect.ratio=0.5) 

#Now use ggsave to save it
#It's best practice to save as a vector image (e.g. .pdf , .eps), but you can also save as a pixellated image (e.g .png , .jpg)
ggsave("/Users/hannahwauchope/Desktop/UglyPlot.pdf", #Specify the filename (and filepath)
       UglyPlot, #Specify the plot we want to save
       device="pdf", #the "device" is what we're saving it as (e.g. pdf, png, jpg whatever)
       width = 150, #Set the width
       height = 80, #Set the height
       units="mm", #Say that our height and width measurements are in mm (This is super useful when journals specify figure sizes)
       dpi=500) #This doesn't mean anything with a pdf/eps but if you're using a pixel image this will define how high res it is

#You can apply this with multi panel plots made with cowplot/gridExtra too, just give the name of whatever you've labelled the plot as. 
