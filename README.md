## **Modelling the spread of HIV using NetLogo**

### *By: Celia Arrecis, Jeevan Auluck, & Alicia Rego*

## Abstract

The goal of this [simulation (link to model)](http://modelingcommons.org/browse/one_model/6312#model_tabs_browse_nlw) is to build an accurate epidemiological model of the spread of HIV through sexual contact and between mother and child. The question to investigate is how following factors influence the transmission rate of HIV the most: the average amount of times people in relationships have sex per month, how often they use condoms or vaginal rings, the length of these committed relationships, how often each individual gets tested for STI’s, and how effective antiretroviral therapy is in preventing the spread of HIV. The results show that increasing condom-use, treatment-efficacy, and commitment reduces the spread of HIV, whereas increasing sexual-activity and testing-frequency increases the spread of HIV. Feel free to play around with the parameters to your liking, then click setup and go to see the magic happen! 

Note: The HIV model written by Wilensky (1997) was used as a reference
to build the foundation of the NetLogo simulation presented in this paper.

## To Setup:

The setup button in the interface clears the world and resets the ticks from the previous run of the program. To begin, the population is set to 1000 turtles, with 20% being infected and unaware. Based on data provided by The World Bank Group (2019), the birth rate was set to 0.5% of the population. The turtles are dispersed throughout the world, and are set to be in the shape of a person. Initially, none of the people are aware of their infection and none of them are in a relationship yet. Additionally, each person is randomly assigned a gender: 0 for males and 1 for females. Gender becomes an important factor when the birth routines and infection-chance are implemented.

Turtles own two variables known as `infected?` and `aware?`. In the model, people who are not infected are denoted with HIV-; people who are infected, but are *not* aware of their infection status are denoted with HIV?; and people who are infected and *are* aware of their infection status are denoted with HIV+. Pressing the setup button assigns each person a colour based on their `infected?` and `aware?` status with the following lines of code:

	if not infected? [set color green]

		if infected? [

			if not aware? [set color yellow]

			if aware? [set color red] ]

The slider variables presented in the interface dictate the *average* values of five variables: `sexual-activity, condom-use, commitment, testing-frequency`, and `treatment- efficacy`. Each turtle is assigned values that are close to these average values set as demonstrated in the following example line of code:

	set sexual-activity random-near average-sexual-activity

with `random-near` being reported as

	random-near [center]

		let result 0

		repeat 40 [set result (result + random-float center)]

		report result / 20

(Wilensky 1997).  The global variables `slider-check-1` through `5` are assigned to the five *average* slider variables presented in the interface.

  

## To Go:

If the user changes any of the slider variables while the program is running, the interface adjusts accordingly to assign each turtle a new value near this average. The following lines of code exemplify how to achieve this for the average-sexual-activity slider variable:

	if (slider-check-1 != average-sexual-activity) [

		ask turtles [assign-sexual-activity]

		set slider-check-1 average-sexual-activity]

For simplicity’s sake, people that are currently in a relationship do not move around, but single people do, moreso if they are not infected. For the people who are infected, they move around more if they are aware compared to those who are unaware of their HIV status. The global variable `months` is set to be the number of ticks as the program is run. Between 0 and 2 months of getting infected, the mobility of unaware individuals is set to 0.8. From 2 to 40 months, mobility is set to 0.7 and after 40 months, it is set to 0.3. These values of mobility become important when plotting the stages of HIV over time.

If two single turtles are found on the same patch, they enter into a relationship with one another, as represented by links. The turtles-own `partnered?` variable is set to be true for both individuals and their commitment to one another is set to be the `commitment-time` value of `end1`.

If the engage-sex? button in the interface is turned on, the following infection chances are used based on the genders of the two ends in the link:

|        Type of Sex        | HIV+ (with treatment) | HIV? (without treatment) |
|:-------------------------:|:---------------------:|:------------------------:|
|    Anal sex (male-male)   |         0.056%        |           1.4%           |
| Vaginal sex (male-female) |        0.0032%        |           0.08%          |
|  Oral sex (female-female) |        0.0016%        |           0.04%          |

If the `engage-sex?` button is turned off, the chance of getting infected via sexual intercourse is the same for everyone, regardless of if they are in a homosexual or heterosexual relationship. This allows the user to visualize the effect of different types of sex acts on the spread of the infection. HIV? individuals behave in the same way as HIV+ people in that their condom use is the same since, as far as they know, they have no sexually transmitted infections. Their chance of spreading the infection depends on this value. However, HIV+ people are more careful about their condom usage. Their chance of spreading the infection also depends on the efficacy of the antiretroviral therapy dictated by the slider variable.

To introduce new individuals into the population, a birth rate is implemented into the model for individuals with `[gender] = 1` (females) that have male partners to perform. HIV- and HIV? women have the same birth rates, but HIV+ women are more reluctant to have babies in fear of passing the infection on to their child. HIV? women have a 14% chance of transmitting the disease to their babies. With antiretroviral therapy reducing the viral load in the blood, there is only a 0.6% chance of an HIV+ woman’s baby also being infected (Public Health Agency of Canada 2012). Furthermore, if average-condom-use is set to 100%, no births occur and HIV is not spread between individuals in the population.

Once a couple’s commitment reaches the number of months defined by the average-commitment slider, they break up. To achieve this, the following lines of code were implemented:

	ask links [

		let initial-commitment commitment + months

		let update-commitment (initial-commitment - months)

		if update-commitment = commitment [

			ask both-ends [set partnered? False]

			die ]]

The program keeps track of how long each HIV+ or HIV? turtle has been infected for. Everyone also has a random probability of getting tested for STI’s. After all these to-go procedures are run, the model reassigns colours based on the new HIV statuses of every individual.

HIV- people have a control death rate in order to project the average life expectancy of the normal healthy individual. HIV+ people have slightly higher death rates, but they do live up to almost normal life expectancies with the help of treatment. HIV? individuals are at a greater risk of dying; as they progress through the stages, their death rate increases.

  

## To Report:

To report the total population, the turtles are counted. Multiplying the amount of links by 2 displays the amount of people in committed relationships and subtracted this number from the total population shows the amount of single people in the population.

To calculate the percentage of people in the population who are infected, red (HIV+) and yellow (HIV?) people are summed and then divided by the total population. The total amount of infected people is simply the sum of the amount of red (HIV+) and yellow (HIV?) turtles. To calculate the percentage of people who are aware of their HIV status, red (HIV+) turtles are divided by the total amount of infected people. Similarly, to calculate the percentage of people who are unaware of their HIV status, yellow (HIV?) turtles are divided by the total amount of infected people.

  

## To Plot:

To plot the progression of the 3 stages of HIV, the mobilities assigned to each turtles depending on how long they have been infected are used. The following line of code is an example of how to graph the acute HIV infection stage:

	set-current-plot-pen "Stage 1"

	set Stage1 (count turtles with [mobility = 0.8])

	plotxy months Stage1

  

## Assumptions of the Model:

-   Condoms are 100% effective in preventing the spread of HIV and pregnancy.
    
-   People who know they are HIV+ always inform their partners of their status and they are 1.5 times more likely to use condoms than the average HIV- person.
    
-   Everyone has access to STI testing and can afford treatment if they are HIV+.
    
-   If a person is in a relationship, they are committed to that one person ie. no one engages in affairs.
    
-   Male-male couples only engage in anal sex, male-female couples only engage in vaginal sex, and female-female relationships only engage in oral sex.
    
-   HIV+ people are 1.5 times more likely to use condoms compared to HIV- or HIV? people.
    
-   Only biological babies of heterosexual relationships are introduced into the population; no babies that homosexual couples adopt are introduced to interact with others
    
-   When babies are born, they have the same probability of engaging in sexual relationships as everyone else, instead of waiting until they are old enough to do so.
    
-   Individuals either die of HIV/AIDS or naturally ie. no accidental deaths or deaths caused by other diseases are accounted for
