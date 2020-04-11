globals [
  pop ; total number of people in this closed population
  months
  dt
  HIV+ ; people who have tested positive for HIV & take medication that lowers their risk of passing it on (red)
  HIV- ; people who have tested negative for HIV (green)
  HIV? ; people who have HIV, but haven't been tested for it yet so they have a higher chance of passing it on (yellow)
  Stage1 ; acute
  Stage2 ; clinical latency
  Stage3 ; AIDS
  slider-check-1
  slider-check-2
  slider-check-3
  slider-check-4
  slider-check-5
]


turtles-own [
  b ; birth rate
  infected? ; an individual may have (true) or may not have (false) HIV
  aware? ; assuming infected? is true, the individual is either aware (true) or unaware (false) that they have HIV
  gender ; 0 for male, 1 for female
  partnered? ; if true, this person is currently engaging in sexual activity
  mobility ;1 person moves, 0 person stop moving when coupled
  ;partner ; the other person in a sexual relationship
  sexual-activity ; how often sex will occur per month for the average couple
  condom-use ; we assume that condoms are 100% effective in preventing the spread of HIV ie. 100% condom use means no spread of HIV
  commitment-time ; how sexually-active a person is based on how long they are willing to stay with people
  testing-frequency ; how often each individual gets tested for STIs
  treatment-efficacy ; every HIV+ person recevies treatment, but it might be less effective in some people
  months-infected ; number of months infected for
  update-months
]

links-own [
  commitment ; commitment length in months for partners
  infection-chance ; the chance of contracting HIV if you have unprocted sex with an infected partner
]

to setup
  clear-all
  setup-globals
  setup-people
  ask turtles [
    set b 5
  ]
  reset-ticks
  plot-pop
  plot-stages
end

to setup-globals
  set pop 1000 ; change this number to increase or decrease the amount of people in this population
  set slider-check-1 average-sexual-activity
  set slider-check-2 average-condom-use
  set slider-check-3 average-commitment
  set slider-check-4 average-testing-frequency
  set slider-check-5 average-treatment-efficacy
end

to setup-people
  crt pop [
    setxy random-xcor random-ycor
    set shape "person"
    set size 1
    ifelse random 2 = 0
      [set gender 0]
      [set gender 1]
    set infected? (who < pop * 0.20)
    set partnered? false
    set aware? false
    set mobility 1
    set months-infected 0
    assign-color
    assign-sexual-activity
    assign-condom-use
    assign-commitment
    assign-testing-frequency
    assign-treatment-efficacy
  ]
end

to assign-color
  if not infected? [set color green]
  if infected? [
    if not aware? [set color yellow]
    if aware? [set color red]
  ]
end



to assign-sexual-activity
  set sexual-activity random-near average-sexual-activity
end

to assign-condom-use
  set condom-use random-near average-condom-use
end

to assign-commitment
  set commitment-time random-near average-commitment
end
to assign-testing-frequency
  set testing-frequency random-near average-testing-frequency
end

to assign-treatment-efficacy
  set treatment-efficacy random-near average-treatment-efficacy
end

to-report random-near [center]
  let result 0
  repeat 40 [set result (result + random-float center)]
  report result / 20
end




to go
  if not any? turtles [stop]
  check-sliders
  ask turtles [move]
  ask turtles [couple]
  ask turtles [
    if months > 40 [ ; once stage 3 can be achieved
    if partnered? [
      if (average-condom-use) < 100 [
        infect
        if gender = 1 [
          birth
        ]
      ]
    ]
  ]
  ]
  ask turtles [assign-color]
  ask turtles [stop-coupling]
  ask turtles [STI-test]
  ask turtles [assign-color]
  ask turtles [death]

  tick
  set months ticks
  plot-pop
  plot-stages
end



; updates the output after every tick if any of the slider variables are changed
to check-sliders
   if (slider-check-1 != average-sexual-activity) [
    ask turtles [assign-sexual-activity]
    set slider-check-1 average-sexual-activity]

  if (slider-check-2 != average-condom-use) [
    ask turtles [assign-condom-use]
    set slider-check-2 average-condom-use]

  if (slider-check-3 != average-commitment) [
    ask turtles [assign-commitment]
    set slider-check-3 average-commitment]

  if (slider-check-4 != average-testing-frequency) [
    ask turtles [assign-testing-frequency]
    set slider-check-4 average-testing-frequency]

  if (slider-check-5 != average-treatment-efficacy) [
    ask turtles [assign-treatment-efficacy]
    set slider-check-5 average-treatment-efficacy]
end



to move
  if partnered? [
    set mobility 0
    fd mobility
  ]
  if not partnered?[
    ifelse not infected? [
      set mobility 1.2
      rt random-float 360
      fd mobility
    ]
    [ifelse not aware? [
       if update-months <= 2 and update-months > 0 [ set mobility 0.8 ]
    if update-months <= 40 and update-months > 2[ set mobility 0.7 ]
    if update-months > 40 [ set mobility 0.3]
      rt random-float 180
    fd mobility
      ]
      [
        set mobility 1
        rt random-float 360
        fd mobility
    ]
    ]
  ]
end



to couple
 if count turtles-on patch-here >= 2 [
  let target one-of other turtles-here; target is any person on the patch that is not partnered
    if [partnered?] of target = false and partnered? = false [ ; makes sure that everyone has one partner
        create-link-with target
        ask links [
          ask both-ends [set partnered? true]
          set commitment [commitment-time] of end1
        ]
      ]
    ]
end

to infect
  ifelse engage-sex? [
    ask links [
  if not [infected?] of end1 and not [infected?] of end2 [set infection-chance 0] ; both HIV-

  if [infected?] of end1 or [infected?] of end2 [
    if [aware?] of end1 or [aware?] of end2 [ ; one partner is HIV+
      if [gender] of end1 = 0 and [gender] of end2 = 0 [set infection-chance 0.056] ;male-male
      if [gender] of end1 = 0 and [gender] of end2 = 1 [set infection-chance 0.0032] ;male-female
      if [gender] of end1 = 1 and [gender] of end2 = 0 [set infection-chance 0.0032] ;female-male
      if [gender]of end1 = 1 and [gender] of end2 = 1 [set infection-chance 0.0016] ;female-female
      ]
    if not [aware?] of end1 or not [aware?] of end2 [ ; one partner is HIV?
      if [gender] of end1 = 0 and [gender] of end2 = 0 [set infection-chance 1.4] ;male-male
      if [gender] of end1 = 0 and [gender] of end2 = 1 [set infection-chance 0.08] ;male-female
      if [gender] of end1 = 1 and [gender] of end2 = 0 [set infection-chance 0.08] ;female-male
      if [gender]of end1 = 1 and [gender] of end2 = 1 [set infection-chance 0.04] ;female-female
      ]
  ]

  if [infected?] of end1 and [infected?] of end2 [set infection-chance 100] ; both HIV+ / HIV?
  ]
  if partnered? [
    repeat sexual-activity [
      ask links [
        if random 100 < infection-chance and infection-chance != 100 [
          ask both-ends [
              set infected? true
              if not aware? [
                set aware? false
                set months-infected months
              ]
            ]
        ]
      ]
    ]
  ]
  ]
  [
    if partnered? [
    repeat sexual-activity [
      if infected? and not aware? [
        ask links [
          if random-float 100 > ([condom-use] of end1) or random-float 100 > ([condom-use] of end2) [ ; HIV? are equally as likely to use a condom as HIV- people
            ask both-ends [
                set infected? true
              if not aware? [
                  set aware? false
                set months-infected months
                ]
              ]
          ]
        ]
      ]
      if infected? and aware? [
        ask links [
          if random 100 > (([condom-use] of end1) * 1.5) or random 100 > (([condom-use] of end2) * 1.5) [ ; if the person is HIV+, they're 2 times more likely to use a condom than an HIV? person
              if random 100 > ([treatment-efficacy] of end1) or random 100 > ([treatment-efficacy] of end2) [
                ask both-ends [
                  set infected? true
                if not aware? [
                    set aware? false
                    set months-infected months
                  ]
              ]
            ]
        ]
        ]
      ]
    ]
  ]
  ]
end



to birth
  if random-float 100 < b [
    if not infected? [ ; mother is unifected (HIV-)
      hatch 1 [
        set partnered? false
        set infected? false
        right random 360
        forward 15
      ]
    ]

    if infected? [
      if aware? [ ; mother is infected and aware (HIV+)
        ;if random-float 100 < b  [ ; more reluctant to give birth
          hatch 1 [
            set partnered? false
            set aware? false
            set infected? false
            if random 100 < 14 [ set infected? true ] ; antiveoral therapy reduces the risk of passing HIV from mother to baby
            right random 360
            forward 15
          ]
       ; ]
      ]

      if not aware? [ ; mother is infected and unaware (HIV?)
        if random-float 100 < b - 3 [ ; more reluctant to give birth
        hatch 1 [
          move
          set partnered? false
          set aware? false
          set infected? false
          if random 100 < 0.6 [ set infected? true ] ; higher chance of passing HIV from mother to baby
          right random 360
          forward 15
          ]
        ]
      ]
    ]
  ]

end



to stop-coupling
  ask links [
    let initial-commitment commitment + months
    let update-commitment (initial-commitment - months)  ; updates commitment and once time in months has passed, link ends
    if update-commitment = commitment [ ; if a person's partner's commitment length is longer than theirs, they break up
      ask both-ends [set partnered? false]
      die ; kills link
    ]
  ]
end



to STI-test
  if infected? and not aware? [
    set update-months (months - months-infected)
  ]
  if random-float 12 < testing-frequency [
    if infected? [
      set aware? true
    ]
  ]
end



to death
  if not infected? [ if random 100 <  1 [ die ] ]

  if infected? [
    if not aware? [
      if mobility = 0.8 [
        if random 100 < 2.5 [ die ]
      ]
      if mobility = 0.7 [ if random 100 < 3 [ die ] ]
      if mobility = 0.3 [ if random 100 < 4.5 [ die ] ]
    ]
    if aware? [
      if random 100 < 1 [ die ]
    ]
  ]
end

to-report total-coupled ; number of people coupled (not pairs)
  report (count links * 2)
end


to-report %infected ; total percentage of people who have HIV, regardless of whether they know it or not
  report ((count turtles with [color = red] + count turtles with [color = yellow]) / count turtles) * 100
end

to-report %hiv+ ;total percentage of people who are aware they have hiv
  let total-infected (count turtles with [color = red] + count turtles with [color = yellow])
  report ((count turtles with [color = red])/ total-infected) * 100
end

to-report %hiv? ;total percentage of people who are not aware they have hiv
  let total-infected (count turtles with [color = red] + count turtles with [color = yellow])
  report ((count turtles with [color = yellow])/ total-infected) * 100
end

to-report total-population
  report (count turtles)
end

to-report total-single ; number of single people
  report (count turtles - (count links * 2))
end

to plot-stages
  set-current-plot "HIV Stages"
  set-current-plot-pen "Stage 1"
  set Stage1 (count turtles with [mobility = 0.8])
  plotxy months Stage1
  set-current-plot-pen "Stage 2"
  set Stage2 (count turtles with [mobility = 0.7])
  plotxy months Stage2
  set-current-plot-pen "Stage 3"
  set Stage3 (count turtles with [mobility = 0.3])
  plotxy months Stage3
end


to plot-pop
  set-current-plot "Population"
  set-current-plot-pen "HIV+"
  set HIV+ (count turtles with [color = red])
  plotxy months HIV+

  set-current-plot-pen "HIV-"
  set HIV- (count turtles with [color = green])
  plotxy months HIV-

  set-current-plot-pen "HIV?"
  set HIV? (count turtles with [color = yellow])
  plotxy months HIV?
end
