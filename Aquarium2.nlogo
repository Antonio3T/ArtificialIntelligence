globals [
  countcells

  x
  y

  num-fish-right
  num-fish-left
  sum-right-turns
  sum-left-turns

  males
  females
  n-platy-fish
  n-guppy-fish
  totalfish

  fish-age
  snail-age
  ;;guppy-age

  watergood
  n-newborn
  n-eaten
  n-starved
  n-old-age
  n-pollution

  ;;garbage

  message-shown-change-water? replace-water
]

turtles-own [fishhealth energy age platy-leader guppy-leader platy-follower guppy-follower]

patches-own [food-rot]

breed [male-platy male-platy-fish]
breed [female-platy female-platy-fish]
breed [male-guppy male-guppy-fish]
breed [female-guppy female-guppy-fish]

breed [fish-food food]

;;breed [algas caracois]
breed [snails snail]







to init-vars
  set sum-right-turns 0
  set sum-left-turns 0

  ask patches [set food-rot 0]
end

to create-fish
  set shape "fishr"

  ;;set pen-size 3
  set size 2.5

  ;;set heading 0
  set heading one-of [0 90 180 270 360]
  setxy -16 + (random(32)) -16 + (random(32))

  set fish-age 0
end

to create-snail
  set shape "bug"
  set size 1.5

  set heading one-of [90 270]
  setxy -16 + (random(32)) -15

  set color green

  set snail-age 0
  set energy 50
end







to setup-snail
  create-snails number-of-snails
  [create-snail]
end

to setup-fish
  create-male-platy number-of-male-platy-fish
  [
    create-fish
    set color orange

    ;;setxy random-float world-width
          ;;random-float world-height

    set energy 30

    set platy-leader nobody
    set platy-follower nobody
  ]

  create-female-platy number-of-female-platy-fish
  [
    create-fish
    set color orange

    set energy 30

    set platy-leader nobody
    set platy-follower nobody
  ]

  create-male-guppy number-of-male-guppy-fish
  [
    create-fish
    set color yellow

    set energy 30

    set guppy-leader nobody
    set guppy-follower nobody
  ]

  create-female-guppy number-of-female-guppy-fish
  [
    create-fish
    set color yellow

    set energy 30

    set guppy-leader nobody
    set guppy-follower nobody
  ]

  set watergood 80
end







to setup
  clear-all

  ;;ask patches [set pcolor blue]

  ;;create-turtles 1 [
  ;;set shape "fish"

  ;;set color White
  ;;set size 2.5

  ;;setxy 0 0
  ;;set heading one-of [0 90 180 270]
  ;;]

  setup-water
  setup-floor
  setup-fish
  setup-snail

  init-vars

  reset-ticks
end

to go
  set num-fish-right 0
  set num-fish-left 0

  ;;ask turtles
  ;;ask male-platy
  ;;[
    ;;ifelse ((random 2) = 0)
    ;;[
      ;;go-left
      ;;set num-fish-left (num-fish-left + 1)
    ;;]
    ;;[
      ;;go-right
      ;;set num-fish-right (num-fish-right + 1)
    ;;]
    ;;set garbage garbage + 1
    ;;check-water
  ;;]

  ask turtles with [breed = male-platy or breed = female-platy or breed = male-guppy or breed = female-guppy]
  [
    fd .5  ;; wander around and look for food]
    ifelse ((random 2) = 0)
    [
      lt random 16
      set num-fish-left (num-fish-left + 1)
    ]
    [
      rt random 16
      set num-fish-right (num-fish-right + 1)
    ]
    set energy energy - .05
    set age age + .1
    bounce
  ]

  ask turtles with [breed = male-platy or breed = female-platy][
    if random-float 1 < probability-follow
    [
      if platy-leader = nobody [attach-platy]
      turn-platy

      fd .5  ;; wander around and look for food]
      ifelse ((random 2) = 0)
      [
        lt random 16
        set num-fish-left (num-fish-left + 1)
      ]
      [
        rt random 16
        set num-fish-right (num-fish-right + 1)
      ]
      set energy energy - .05
      set age age + .1
      bounce
    ]
  ]

  ask turtles with [breed = male-guppy or breed = female-guppy][
    if random-float 1 < probability-follow
    [
      if guppy-leader = nobody [attach-guppy]
      turn-guppy

      fd .5  ;; wander around and look for food]
      ifelse ((random 2) = 0)
      [
        lt random 16
        set num-fish-left (num-fish-left + 1)
      ]
      [
        rt random 16
        set num-fish-right (num-fish-right + 1)
      ]
      set energy energy - .05
      set age age + .1
      bounce
    ]
  ]


  ask turtles with [breed = snails]
  [
    ifelse ((random 2) = 0)
    [
      forward 1
    ]
    [
      set heading (- heading)
      bounce
      forward 1
    ]
    bounce
  ]

  ;ask turtles [if platy-leader = nobody [attach-platy] if guppy-leader = nobody [attach-guppy]]
  ;ask turtles [turn-platy turn-guppy]

  if count turtles = 0
  [
    stop
  ]

  spawn
  follow-fish
  eat
  food-down
  kickbucket
  monitor-water
  if cannibalism
  [
    eat-smaller-fish
  ]
  pollute-water
  color-water
  filterwater
  count-fish


  set sum-right-turns (sum-right-turns + num-fish-right)
  set sum-left-turns (sum-left-turns + num-fish-left)
  set countcells countcells + (sum-left-turns + sum-right-turns)

  tick
end







to feed-fish
  create-fish-food amount-food?
  [
    set shape "circle"
    set color white
    set pen-size 3
    ;;set size 2.5

    set x -16 + (random (33))
    setxy x 16

    ;;set heading 0
    ;;set heading one-of [0 90 180 270 360]
    set heading 180

    ;;set food-rot 0
  ]
end

to eat
  ask turtles with [breed = male-platy or breed = female-platy or breed = male-guppy or breed = female-guppy]
  [
    ;;if any? (turtles-on patch-ahead 2) with [breed = fish-food]
    if any? (turtles-on patch-here) with [breed = fish-food]
    [
      ask (turtles-on patch-here) with [breed = fish-food]
      [
        die
      ]
      set energy energy + 21
      if size < 4
      [set size size + .2]
      set watergood watergood - .01
    ]
  ]
end







to spawn
  if random-float 1 < probability-spawn
  [
    if watergood > 60[
      ifelse ((random 2) = 0)
      ;;ifelse ((random probability-spawn) = 0)

      [ask turtles with [ breed = female-platy and (energy >= 30) and (size >= 3)]
        [if any? (male-platy in-radius 5) with [ (energy >= 30) and (size >= 3)]
          [
            hatch 20
            [
              set n-newborn n-newborn + 1
              set age 0
              set size 1
              set energy 15

              ifelse random 2 = 0
              [
                set breed male-platy
              ]
              [
                set breed female-platy
              ]

              set color orange
              set shape "fishr"

              ;;lt 45
              ;;fd 3
            ]
          ]
        ]
      ]
      [ask turtles with [breed = female-guppy and (energy >= 30) and (size >= 3)]
        [if any? (male-guppy in-radius 5) with [ (energy >= 30) and (size >= 3)]
          [
            hatch 20
            [
              set n-newborn n-newborn + 1
              set age 0
              set shape "fishr"
              set size 1
              set energy 15

              ifelse random 2 = 0
              [
                set breed male-guppy
              ]
              [
                set breed female-guppy
              ]

              set color yellow
              set shape "fishr"
            ]
          ]
        ]
      ]
    ]
  ]
end

to kickbucket
  ask turtles with [breed = male-platy or breed = female-platy or breed = male-guppy or breed = female-guppy]
  [
    if (energy <= 0)  ;;or (age > 80)
    [
      set n-starved n-starved + 1
      die
    ]
    if (age > 80)
    [
      set n-old-age n-old-age + 1
      die
    ]
  ]
  if watergood < 10
  [
    ifelse (count turtles with [breed = male-platy or breed = female-platy or breed = male-guppy or breed = female-guppy] >= 3)  ;; if more than 3 fish, randomly pick one
    [
      ask n-of 3 turtles with [breed = male-platy or breed = female-platy or breed = male-guppy or breed = female-guppy]
      [
        set n-pollution n-pollution + 1
        die
      ]
    ]
    [
      ask turtles with [breed = male-platy or breed = female-platy or breed = male-guppy or breed = female-guppy] [
        set n-pollution n-pollution + 1
        die
      ]
    ]
  ]
end







to eat-smaller-fish  ;; eat fish that are more than .5 smaller than
  let foodenergy 0
  let mysize 0
  set foodenergy 0
  ask turtles with [breed = male-platy or breed = female-platy or breed = male-guppy or breed = female-guppy]
  [
    set mysize size
    if any? (turtles-on patch-ahead 2) with [size <= (mysize - .25)]
    [
      ask turtles-on patch-ahead 2
      [
        set foodenergy size
        set n-eaten n-eaten + 1
        die
      ]
    ]
    set energy energy + foodenergy
    set watergood watergood - .1
]
end







to follow-fish
  if random-float 1 < probability-follow [
    ask turtles with [breed = male-platy or breed = female-platy]
    [
      if any? (turtles-on patch-ahead 2) with [breed = male-platy or breed = female-platy]
      [
        ;;follow
        if platy-leader = nobody [attach-platy]
        ;turn-platy
      ]
    ]

    ask turtles with [breed = male-guppy or breed = female-guppy]
    [
      if any? (turtles-on patch-ahead 2) with [breed = male-guppy or breed = female-guppy]
      [
        ;;follow
        if guppy-leader = nobody [attach-guppy]
        ;turn-guppy
      ]
    ]
  ]
end

to attach-platy
  ;;let xd near-radius + random (far-radius - near-radius)
  ;;let yd near-radius + random (far-radius - near-radius)

  ;;if random 2 = 0 [set xd (- xd)]
  ;;if random 2 = 0 [set yd (- yd)]

  let platy-candidate one-of turtles with [(breed = male-platy or breed = female-platy) and platy-follower = nobody]

  if (platy-candidate = nobody) [stop]
  ask platy-candidate [set platy-follower myself]
  set platy-leader platy-candidate

  ;ifelse platy-follower = nobody[] [set color red];;change color]
  ;ifelse platy-leader = nobody[] [set color red];;change color]
end

to turn-platy
  ifelse platy-leader = nobody
  []
  [face platy-leader]
end

to attach-guppy
  ;;let xd near-radius + random (far-radius - near-radius)
  ;;let yd near-radius + random (far-radius - near-radius)

  ;;if random 2 = 0 [set xd (- xd)]
  ;;if random 2 = 0 [set yd (- yd)]

  let guppy-candidate one-of turtles with [(breed = male-guppy or breed = female-guppy) and guppy-follower = nobody]

  if (guppy-candidate = nobody) [stop]
  ask guppy-candidate [set guppy-follower myself]
  set guppy-leader guppy-candidate

  ;;ifelse follower = nobody [change color]
  ;;ifelse leader = nobody [change color]
end

to turn-guppy
  ifelse guppy-leader = nobody
  []
  [face guppy-leader]
end







to setup-water
  ask patches
  [set pcolor blue]
end

to pollute-water
  let big-fish 0
  let little-fish 0
  let bigpollutes 0
  let littlepollutes 0

  set big-fish count turtles with [size >= 3.5]
  set little-fish count turtles with [size < 3.5]
  set bigpollutes big-fish * .003
  set littlepollutes little-fish * .005
  set watergood watergood - (bigpollutes + littlepollutes)
end

to filterwater
  if watergood < 100
  [
    set watergood watergood + filterflow? / 25
    ask patches with [food-rot > 0][set food-rot abs((food-rot - filterflow? / 10))]
  ]
end

to change-water
  set replace-water replace-water + 1
  set watergood 100

  ask patches with [food-rot != 0]
  [
    set food-rot 0
    set pcolor blue
  ]

  ;;if (replace-water mod 3 = 0)
  ;;[
    ;;set message-shown-change-water? true
    ;;user-message ("Why do you want to do a partial water change?")]
  if (replace-water mod 5 = 0)
  [
    set message-shown-change-water? true
    user-message ("What is the negative effect of too many water changes?")]
end

to color-water
  if (watergood < 20)
  [
    ask patches with [pcolor = blue and food-rot > 19]
    [
      ;;if random-float 1 < .5 [set pcolor green]
    ]
  ]
end







to setup-floor
  ask patches with [pxcor >= -16 and pxcor <= 16 and pycor = -16] [set pcolor yellow]
end

to food-down
  ask fish-food
  [
    if (abs [pxcor] of patch-ahead 1 = 16)
    [
      ifelse (abs [pycor] of patch-ahead 1 = max-pycor)[stop]
      [forward 1]
    ]
    if (abs [pxcor] of patch-ahead 1 = max-pxcor)[stop]
    if (abs [pycor] of patch-ahead 1 = max-pycor)[stop]
    forward 1

    ask patch-here [set food-rot food-rot + .01]

    ask patch-here [
      if (food-rot > 19)
      [
        ;;if random-float 1 < 0.19 [set pcolor green]
        if random-float 1 < 0.1 [set pcolor scale-color green food-rot 0 150]
      ]
    ]
  ]
end

to go-right
  rt 90
  forward 1
  set countcells countcells + 1
  food-down
end

to go-left
  lt 90
  forward 1
  set countcells countcells + 1
  food-down
end

to size-fish
  let largefish count turtles with [size >= 3.5]
  let smallfish count turtles with [size < 3.5]
end

to count-fish
  let n-male-platy count male-platy
  let n-female-platy count female-platy

  let n-male-guppy count male-guppy
  let n-female-guppy count female-guppy


  let platys n-male-platy + n-female-platy
  let guppys n-male-guppy + n-female-guppy


  ;;let number-of-platy-fish count turtles with [breed = male-platy or breed = female-platy]
  ;;let number-of-guppy-fish count turtles with [breed = male-guppy or breed = female-guppy]


  set males n-male-platy + n-male-guppy
  set females n-female-platy + n-female-guppy

  set n-platy-fish platys
  set n-guppy-fish guppys
  set totalfish males + females
end







to bounce
  if (abs [pxcor] of patch-ahead 1 = max-pxcor)
  [ set heading (- heading) ]

  if (abs [pycor] of patch-ahead 1 = max-pycor)
  [ set heading (180 - heading) ]
end







to feed
  ;;set x -16 + (random(32))

  ;;ask n-of amount-food? patches with [pxcor = x and pycor = max-pycor]
  ;;[if pcolor = blue
    ;;[
      ;;set pcolor white
      ;;set food-rot 0
    ;;]
  ;;]
  ;;ask turtles
  ;;[
    ;;if pcolor = white
    ;;[
      ;;set pcolor blue
      ;;set energy energy + 10
      ;;if size < 4
      ;;[set size size + .2]
    ;;]
  ;;]
end

to check-water
  ;;if garbage > 1000 [set pcolor green]
end

to monitor-water
  ;;ask patches
  ;;[
    ;;if pcolor = white
    ;;[
      ;;set food-rot food-rot + random-float 1
      ;;if food-rot > 40
      ;;[
        ;;if watergood > 0
        ;;[
          ;;set watergood watergood - .1
          ;;set food-rot 0
          ;;set pcolor green
        ;;]
      ;;]
    ;;]
  ;;]
end
@#$#@#$#@
GRAPHICS-WINDOW
665
181
1192
709
-1
-1
15.73
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
554
181
659
238
Setup
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
465
397
659
430
number-of-male-platy-fish
number-of-male-platy-fish
1
100
7.0
1
1
NIL
HORIZONTAL

BUTTON
596
243
659
276
NIL
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1383
385
1495
430
Total Cells Traveled
countcells
0
1
11

MONITOR
1241
385
1302
430
Left Turns
sum-left-turns
0
1
11

MONITOR
1308
385
1376
430
Right Turns
sum-right-turns
0
1
11

SLIDER
458
476
659
509
number-of-male-guppy-fish
number-of-male-guppy-fish
1
100
7.0
1
1
NIL
HORIZONTAL

SLIDER
519
329
659
362
amount-food?
amount-food?
1
1000
17.0
1
1
NIL
HORIZONTAL

BUTTON
434
328
515
361
NIL
feed-fish
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1241
182
1540
376
Evolution
Time
Population
0.0
1000.0
-100.0
150.0
true
true
"" ""
PENS
"Fish" 1.0 0 -16777216 true "" "plot totalfish"
"Guppy Fish" 1.0 0 -723837 true "" "plot n-guppy-fish"
"Platy Fish" 1.0 0 -612749 true "" "plot n-platy-fish"
"Males" 1.0 0 -6759204 true "" "plot males"
"Females" 1.0 0 -1264960 true "" "plot females"

SLIDER
454
433
659
466
number-of-female-platy-fish
number-of-female-platy-fish
1
100
7.0
1
1
NIL
HORIZONTAL

SLIDER
447
514
659
547
number-of-female-guppy-fish
number-of-female-guppy-fish
1
100
7.0
1
1
NIL
HORIZONTAL

SLIDER
487
567
659
600
probability-spawn
probability-spawn
0
1
0.3
.1
1
NIL
HORIZONTAL

SLIDER
487
603
659
636
filterflow?
filterflow?
100
1000
1000.0
10
1
NIL
HORIZONTAL

BUTTON
477
243
586
276
NIL
change-water
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1242
439
1542
649
Genders Evolution
Time
Population
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Male" 1.0 0 -6759204 true "" "plot males"
"Females" 1.0 0 -1264960 true "" "plot females"

PLOT
1555
182
1783
374
 Species Evolution
Time
Population
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Guppy Fish" 1.0 0 -723837 true "" "plot n-guppy-fish"
"Platy Fish" 1.0 0 -612749 true "" "plot n-platy-fish"

MONITOR
1243
657
1345
702
Starving Deaths
n-starved
0
1
11

MONITOR
1351
657
1429
702
Age Deaths
n-old-age
0
1
11

MONITOR
1435
657
1537
702
Pollution Deaths
n-pollution
0
1
11

MONITOR
1550
439
1640
484
Water Quality
watergood
3
1
11

MONITOR
1551
491
1620
536
Newborns
n-newborn
0
1
11

PLOT
1649
438
1849
588
Water Quality
Water Quality
Time
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Water Quality" 1.0 0 -8862290 true "" "plot watergood"

MONITOR
1543
657
1614
702
Fish Eaten
n-eaten
0
1
11

SLIDER
487
641
659
674
number-of-snails
number-of-snails
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
308
566
480
599
probability-follow
probability-follow
0
1
0.0
.1
1
NIL
HORIZONTAL

SWITCH
1620
657
1761
690
cannibalism
cannibalism
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

fishr
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
