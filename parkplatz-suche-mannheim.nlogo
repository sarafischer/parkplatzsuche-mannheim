extensions [ gis nw rnd ]
globals [
  roads-dataset ; gis data
  temp-spawn ; holds a spawn-point, used to check if patch is empty and car can be created
  average-parking-fees ; list of average parking fees per hours to pay (1 hour = 2€, 2 hours = 3.8€ ...)
  willingness-to-pay ; list of factors that determine the wtp according to a possible income in Germany
  no-parking-space-found ;tracker variable that counts all cars that were unable to find a parking space regardless of the reason
  counter-cars-finished ; counter for cars that found parking space or gave up the search
  counter-cars-finished-type-1
  counter-cars-finished-type-2
  counter-cars-finished-wtp-0.6
  counter-cars-finished-wtp-0.7
  counter-cars-finished-wtp-1
  counter-cars-finished-wtp-1.45
  counter-cars-finished-wtp-2
  counter-cars-finished-wtp-2.32
  counter-cars-not-entering-city-wtp-0.6
  counter-cars-not-entering-city-wtp-0.7
  counter-cars-not-entering-city-wtp-1
  counter-cars-not-entering-city-wtp-1.45
  counter-cars-not-entering-city-wtp-2
  counter-cars-not-entering-city-wtp-2.32
  counter-cars-who-searched-successfully ; tracker of total cars that have a time-searched above 0 and found a parking space
  total-search-time
  total-search-time-type-1
  total-search-time-type-2
  total-search-time-wtp-0.6
  total-search-time-wtp-0.7
  total-search-time-wtp-1
  total-search-time-wtp-1.45
  total-search-time-wtp-2
  total-search-time-wtp-2.32
  total-search-time-cars-who-searched
  total-search-time-cars-who-searched-successfully

  counter-cars-found-parking-space
  counter-cars-found-parking-space-type-1
  counter-cars-found-parking-space-type-2
  counter-cars-found-parking-space-wtp-0.6
  counter-cars-found-parking-space-wtp-0.7
  counter-cars-found-parking-space-wtp-1
  counter-cars-found-parking-space-wtp-1.45
  counter-cars-found-parking-space-wtp-2
  counter-cars-found-parking-space-wtp-2.32
  total-distance-to-destination
  total-distance-to-destination-type-1
  total-distance-to-destination-type-2
  total-distance-to-destination-wtp-0.6
  total-distance-to-destination-wtp-0.7
  total-distance-to-destination-wtp-1
  total-distance-to-destination-wtp-1.45
  total-distance-to-destination-wtp-2
  total-distance-to-destination-wtp-2.32

  ; total-distance-travelled equals distance covered until parking space is found or car gives up searching
    ; distance that is travelled while leaving the city is not included
  total-distance-travelled
  total-distance-travelled-type-1
  total-distance-travelled-type-2
  total-distance-travelled-wtp-0.6
  total-distance-travelled-wtp-0.7
  total-distance-travelled-wtp-1
  total-distance-travelled-wtp-1.45
  total-distance-travelled-wtp-2
  total-distance-travelled-wtp-2.32

  counter-cars-who-searched ; tracker of total cars that have a time-searched above 0
  counter-cars-who-searched-type-1
  counter-cars-who-searched-type-2
  counter-cars-who-searched-wtp-0.6
  counter-cars-who-searched-wtp-0.7
  counter-cars-who-searched-wtp-1
  counter-cars-who-searched-wtp-1.45
  counter-cars-who-searched-wtp-2
  counter-cars-who-searched-wtp-2.32
  total-distance-searched
  total-distance-searched-type-1
  total-distance-searched-type-2
  total-distance-searched-wtp-0.6
  total-distance-searched-wtp-0.7
  total-distance-searched-wtp-1
  total-distance-searched-wtp-1.45
  total-distance-searched-wtp-2
  total-distance-searched-wtp-2.32

  counter-spawned-cars ; tracker variable that counts the cars that were created
  counter-spawned-cars-type-1
  counter-spawned-cars-type-2
  counter-spawned-cars-wtp-0.6
  counter-spawned-cars-wtp-0.7
  counter-spawned-cars-wtp-1
  counter-spawned-cars-wtp-1.45
  counter-spawned-cars-wtp-2
  counter-spawned-cars-wtp-2.32
  total-failed-attempts
  total-failed-attempts-type-1
  total-failed-attempts-type-2
  total-failed-attempts-wtp-0.6
  total-failed-attempts-wtp-0.7
  total-failed-attempts-wtp-1
  total-failed-attempts-wtp-1.45
  total-failed-attempts-wtp-2
  total-failed-attempts-wtp-2.32

  total-occupancy
  total-parking-spaces
]

breed [ nodes node ]
breed [parking-nodes parking-node]
breed [spawn-nodes spawn-node ]
breed [ cars car ]

cars-own [
  current-location ; last visited node
  parking-spaces-in-parking-radius ; list of nodes that are parking-spaces within the user-specified parking-radius
  parking-spaces-in-parking-radius-copy
  closest-parking-space ; parking space that is closest to the destination, regardless the price
  most-affordable-parking-space ; list of affordable parking spaces, usually hold one item, but if two parking spaces have equal fees both are stored
  parking-space ; chosen parking space
  destination ; goal -> where they want to go
  spawn ; start
  allowed-travel-distance ; distance car is allowed to travel per second according to speed-limit in Netlogo-Units
  distance-to-next-node ; distance car still has to travel until the next node is reached
  distance-travelled ;logs distance the car travelled (in Netlogo Units)
  current-second ; holds passed time in current tick
  passed-seconds ; total time the car was on the streets (eventually a fraction of a second more)
  status ; can be driving, waiting, parked
  hours ; amount of hours they want to park, possible: 1-9
  wtp ; factor used to calculate maximum amount that will be spent on a parking space (randomly selected)
  max-fee ; maximum fee willing to pay calculated by hours & wtp
  time-driven
  time-parked
  searching ; true or false, indicates when time-searched has to start/stop
  finished-searching ; true or false, indicates if a car finished the searching-process
  time-searched
  agent-type ; type 1: app-user, type 2: familiar with city
  distance-to-destination ; holds distance from parking-space to destination
]
nodes-own [
  ;weight2 ; meant for debugging link-weight
]

parking-nodes-own [
  occupancy
  capacity
  name
  fees
  original-fees
]

links-own [
  weight ; length of link -> distance between two connected nodes in Netlogo Units
  speed-limit ; in km/h
]

to setup
  clear-all
  reset-ticks
  ask patches [ set pcolor white ]

  gis:load-coordinate-system (word "real_data/mannheim_final_map.prj")
  set roads-dataset gis:load-dataset "real_data/mannheim_final_map.shp"
  gis:set-world-envelope gis:envelope-of roads-dataset

  foreach gis:feature-list-of roads-dataset [ vector-feature ->
    foreach  gis:vertex-lists-of vector-feature [ vertex ->
      let previous-turtle nobody
      foreach vertex [point ->
        let location gis:location-of point
        if not empty? location
        [
          let x item 0 location
          let y item 1 location
          let current-node one-of (turtles-on patch x y) with [ xcor = x and ycor = y ]

          if current-node = nobody [
            create-nodes 1 [
              setxy x y
              set shape "circle"
              set size 0.3
              set color blue
              set hidden? true
              set current-node self
            ]
          ]
          ask current-node [
            if is-turtle? previous-turtle [
              create-link-with previous-turtle [
                set weight link-length
                set speed-limit gis:property-value vector-feature "int_speed"
              ]
            ]
            set previous-turtle self
          ]
        ]
      ]
    ]
  ]
  set-spawn-nodes
  set-parking-nodes
  set average-parking-fees [2 3.8 5.6 7 8.4 9.3 10.2 10.6 10.9]
  set willingness-to-pay [0.6 0.7 1 1.45 2 2.32]
  set-default-shape cars "car"
end

to go
  ask parking-nodes [
    set total-occupancy total-occupancy + occupancy
    set total-parking-spaces total-parking-spaces + capacity
  ]

  if ticks = 86400 [stop]
  ask cars with [status = "parked"] [
    set time-parked time-parked + 1
    if time-parked / 60 / 60 = hours [
      ask parking-space [
        set occupancy occupancy - 1
        if dynamic-pricing = true [
          apply-dynamic-pricing
        ]
      ]
      ;print "leaving"
      set color blue
      set status "leaving"
      set hidden? false
    ]
  ]
  ask parking-nodes [
    set label occupancy
    set label-color red
  ]
  ; check if car can spawn (condition: spawn-patch must be empty)
  set temp-spawn one-of spawn-nodes
  let allowed-to-spawn "false"
  ask temp-spawn [
    if not any? cars-on patch-here [
      set allowed-to-spawn "true"
    ]
  ]
  if ticks mod 11 = 0 and allowed-to-spawn = "true" [
    ; spawn mechanic only works if one car is spawned at the same time
      ; if more are spawned they will all have the same spawn-point -> cars would be driving on top of each other
    create-cars 1 [
      set color red
      set size 9
      set passed-seconds 0
      set current-second 0
      set spawn temp-spawn
      set current-location temp-spawn
      set searching false
      move-to spawn
      set status "driving"
      pick-parking-hours
      pick-wtp
      set-max-fee
      pick-agent-type
    ]
    set counter-spawned-cars counter-spawned-cars + 1
  ]
  ask cars with [status = "driving"] [
    if destination = 0 [
      select-destination
    ]
    if parking-space = 0 [
      if agent-type = "1" [
        select-parking-space
      ]
      if agent-type = "2" [
        get-parking-spaces-in-radius
        get-closest-parking-space-type-2
      ]
    ]
    if agent-type = "1" and status = "driving" [
      move
    ]
    if agent-type = "2" and status = "driving" [
      move
      if current-location = parking-space [
        check-parking-requirements-type-2
      ]
    ]
  ]
  ask cars with [searching = true] [set color black]

  ask cars with [status = "leaving"] [
    leave-city
  ]
  ask cars [
    if searching = true [
      set time-searched time-searched + 1
    ]
    if time-searched = 1800 [
      if status != "leaving" [
        set no-parking-space-found no-parking-space-found + 1
        set color green
        ;print "searched for more than 30min"
        set status "leaving"
        set searching false
        set counter-cars-finished counter-cars-finished + 1
        set counter-cars-who-searched counter-cars-who-searched + 1
        ifelse agent-type = "1"
        [
          set counter-cars-finished-type-1 counter-cars-finished-type-1 + 1
          set counter-cars-who-searched-type-1 counter-cars-who-searched-type-1 + 1
          set total-search-time-type-1 total-search-time-type-1 + time-searched
          set total-distance-travelled-type-1 total-distance-travelled-type-1 + distance-travelled
        ]
        [
          set counter-cars-finished-type-2 counter-cars-finished-type-2 + 1
          set counter-cars-who-searched-type-2 counter-cars-who-searched-type-2 + 1
          set total-search-time-type-2 total-search-time-type-2 + time-searched
          set total-distance-travelled-type-2 total-distance-travelled-type-2 + distance-travelled
        ]
        if wtp = 0.6 [
          set counter-cars-finished-wtp-0.6 counter-cars-finished-wtp-0.6 + 1
          set counter-cars-who-searched-wtp-0.6 counter-cars-who-searched-wtp-0.6 + 1
          set total-search-time-wtp-0.6 total-search-time-wtp-0.6 + time-searched
          set total-distance-travelled-wtp-0.6 total-distance-travelled-wtp-0.6 + distance-travelled
        ]
        if wtp = 0.7 [
          set counter-cars-finished-wtp-0.7 counter-cars-finished-wtp-0.7 + 1
          set counter-cars-who-searched-wtp-0.7 counter-cars-who-searched-wtp-0.7 + 1
          set total-search-time-wtp-0.7 total-search-time-wtp-0.7 + time-searched
          set total-distance-travelled-wtp-0.7 total-distance-travelled-wtp-0.7 + distance-travelled
        ]
        if wtp = 1 [
          set counter-cars-finished-wtp-1 counter-cars-finished-wtp-1 + 1
          set counter-cars-who-searched-wtp-1 counter-cars-who-searched-wtp-1 + 1
          set total-search-time-wtp-1 total-search-time-wtp-1 + time-searched
          set total-distance-travelled-wtp-1 total-distance-travelled-wtp-1 + distance-travelled
        ]
        if wtp = 1.45 [
          set counter-cars-finished-wtp-1.45 counter-cars-finished-wtp-1.45 + 1
          set counter-cars-who-searched-wtp-1.45 counter-cars-who-searched-wtp-1.45 + 1
          set total-search-time-wtp-1.45 total-search-time-wtp-1.45 + time-searched
          set total-distance-travelled-wtp-1.45 total-distance-travelled-wtp-1.45 + distance-travelled
        ]
        if wtp = 2 [
          set counter-cars-finished-wtp-2 counter-cars-finished-wtp-2 + 1
          set counter-cars-who-searched-wtp-2 counter-cars-who-searched-wtp-2 + 1
          set total-search-time-wtp-2 total-search-time-wtp-2 + time-searched
          set total-distance-travelled-wtp-2 total-distance-travelled-wtp-2 + distance-travelled
        ]
        if wtp = 2.32 [
          set counter-cars-finished-wtp-2.32 counter-cars-finished-wtp-2.32 + 1
          set counter-cars-who-searched-wtp-2.32 counter-cars-who-searched-wtp-2.32 + 1
          set total-search-time-wtp-2.32 total-search-time-wtp-2.32 + time-searched
          set total-distance-travelled-wtp-2.32 total-distance-travelled-wtp-2.32 + distance-travelled
        ]
        set total-search-time-cars-who-searched total-search-time-cars-who-searched + time-searched
        set total-search-time total-search-time + time-searched
        set total-distance-travelled total-distance-travelled + distance-travelled
      ]
    ]
  ]
  tick ; 1 second passed
end

to apply-dynamic-pricing
  ;<= 30% -> 0.5 less
  ;> 30% and <= 60% -> 0.25 less
  ;> 60% and <= 80% -> 0 less/more
  ;> 80% -> 0.25 more
  set fees []
  let p30 capacity * 0.3
  let p60 capacity * 0.6
  let p80 capacity * 0.8
  if occupancy <= p30 [
    foreach original-fees [n ->
      let new-fee n - 0.5
      set fees lput new-fee fees
    ]
  ]
  if occupancy > p30 and occupancy <= p60 [
    foreach original-fees [n ->
      let new-fee n - 0.25
      set fees lput new-fee fees
    ]
  ]
  if occupancy > p60 and occupancy <= p80 [
    set fees original-fees
  ]
  if occupancy > p80 [
    foreach original-fees [n ->
      let new-fee n + 0.25
      set fees lput new-fee fees
    ]
  ]
end

to pick-parking-hours
  let pairs [[1 1.64] [2 29.12] [3 65.14] [4 65.14] [5 3.69] [6 3.69] [7 3.69] [8 3.69] [9 0.41]]
  set hours first rnd:weighted-one-of-list pairs [ [p] -> last p ]
end

to pick-agent-type
  ifelse random 100 < amount-app-user
  [
    set agent-type "1"
    set counter-spawned-cars-type-1 counter-spawned-cars-type-1 + 1
  ]
  [
    set agent-type "2"
    set counter-spawned-cars-type-2 counter-spawned-cars-type-2 + 1
  ]
end

to pick-wtp
  set wtp one-of willingness-to-pay
  if wtp = 0.6 [ set counter-spawned-cars-wtp-0.6 counter-spawned-cars-wtp-0.6 + 1 ]
  if wtp = 0.7 [ set counter-spawned-cars-wtp-0.7 counter-spawned-cars-wtp-0.7 + 1 ]
  if wtp = 1 [ set counter-spawned-cars-wtp-1 counter-spawned-cars-wtp-1 + 1 ]
  if wtp = 1.45 [ set counter-spawned-cars-wtp-1.45 counter-spawned-cars-wtp-1.45 + 1 ]
  if wtp = 2 [ set counter-spawned-cars-wtp-2 counter-spawned-cars-wtp-2 + 1 ]
  if wtp = 2.32 [ set counter-spawned-cars-wtp-2.32 counter-spawned-cars-wtp-2.32 + 1 ]
end

to set-max-fee
  let average-parking-fees-index hours - 1
  set max-fee item average-parking-fees-index average-parking-fees * wtp
end

to select-parking-space
  get-parking-spaces-in-radius
  let cheapest-fee 1000
  let temp max-fee
  let fee-index hours - 1
  let same-fees []
  foreach parking-spaces-in-parking-radius [n ->
    ; get price that needs to be paid for the parking space for the desired amount of hours
    let fee-to-pay [item fee-index fees] of n
    ; check if parking space is cheaper than the last one AND fee is affordable AND there is a free parking space
    if fee-to-pay < cheapest-fee and fee-to-pay <= temp and [occupancy] of n < [capacity] of n [
      set cheapest-fee fee-to-pay
      set most-affordable-parking-space n
      set same-fees []
      set same-fees lput n same-fees
    ]
    if fee-to-pay = cheapest-fee and fee-to-pay <= temp and [occupancy] of n < [capacity] of n [
      set same-fees lput n same-fees
    ]
  ]
  set same-fees remove-duplicates same-fees
  if length same-fees = 1 [
    set parking-space item 0 same-fees
  ]
  if length same-fees > 1 [
    set most-affordable-parking-space same-fees
    get-closest-parking-space-type-1
    set parking-space closest-parking-space
  ]
  if length same-fees = 0 and length parking-spaces-in-parking-radius > 0 [
    set no-parking-space-found no-parking-space-found + 1
    if time-searched = 0 [
      if wtp = 0.6 [set counter-cars-not-entering-city-wtp-0.6 counter-cars-not-entering-city-wtp-0.6 + 1]
      if wtp = 0.7 [set counter-cars-not-entering-city-wtp-0.7 counter-cars-not-entering-city-wtp-0.7 + 1]
      if wtp = 1 [set counter-cars-not-entering-city-wtp-1 counter-cars-not-entering-city-wtp-1 + 1]
      if wtp = 1.45 [set counter-cars-not-entering-city-wtp-1.45 counter-cars-not-entering-city-wtp-1.45 + 1]
      if wtp = 2 [set counter-cars-not-entering-city-wtp-2 counter-cars-not-entering-city-wtp-2 + 1]
      if wtp = 2.32 [set counter-cars-not-entering-city-wtp-2.32 counter-cars-not-entering-city-wtp-2.32 + 1]
    ]
    set color green
    ;print "couldn't find or afford a parking space"
    set status "leaving"
    set counter-cars-finished counter-cars-finished + 1
    ifelse agent-type = "1"
        [
          set counter-cars-finished-type-1 counter-cars-finished-type-1 + 1
          set total-search-time-type-1 total-search-time-type-1 + time-searched
          set total-distance-travelled-type-1 total-distance-travelled-type-1 + distance-travelled
        ]
        [
          set counter-cars-finished-type-2 counter-cars-finished-type-2 + 1
          set total-search-time-type-2 total-search-time-type-2 + time-searched
          set total-distance-travelled-type-2 total-distance-travelled-type-2 + distance-travelled
        ]
    if wtp = 0.6 [
      set counter-cars-finished-wtp-0.6 counter-cars-finished-wtp-0.6 + 1
      set total-search-time-wtp-0.6 total-search-time-wtp-0.6 + time-searched
      set total-distance-travelled-wtp-0.6 total-distance-travelled-wtp-0.6 + distance-travelled
    ]
    if wtp = 0.7 [
      set counter-cars-finished-wtp-0.7 counter-cars-finished-wtp-0.7 + 1
      set total-search-time-wtp-0.7 total-search-time-wtp-0.7 + time-searched
      set total-distance-travelled-wtp-0.7 total-distance-travelled-wtp-0.7 + distance-travelled
    ]
    if wtp = 1 [
      set counter-cars-finished-wtp-1 counter-cars-finished-wtp-1 + 1
      set total-search-time-wtp-1 total-search-time-wtp-1 + time-searched
      set total-distance-travelled-wtp-1 total-distance-travelled-wtp-1 + distance-travelled
    ]
    if wtp = 1.45 [
      set counter-cars-finished-wtp-1.45 counter-cars-finished-wtp-1.45 + 1
      set total-search-time-wtp-1.45 total-search-time-wtp-1.45 + time-searched
      set total-distance-travelled-wtp-1.45 total-distance-travelled-wtp-1.45 + distance-travelled
    ]
    if wtp = 2 [
      set counter-cars-finished-wtp-2 counter-cars-finished-wtp-2 + 1
      set total-search-time-wtp-2 total-search-time-wtp-2 + time-searched
      set total-distance-travelled-wtp-2 total-distance-travelled-wtp-2 + distance-travelled
    ]
    if wtp = 2.32 [
      set counter-cars-finished-wtp-2.32 counter-cars-finished-wtp-2.32 + 1
      set total-search-time-wtp-2.32 total-search-time-wtp-2.32 + time-searched
      set total-distance-travelled-wtp-2.32 total-distance-travelled-wtp-2.32 + distance-travelled
    ]
    if time-searched > 0 [
      set counter-cars-who-searched counter-cars-who-searched + 1
      if agent-type = "1" [
        set counter-cars-who-searched-type-1 counter-cars-who-searched-type-1 + 1
      ]
      if agent-type = "2" [
        set counter-cars-who-searched-type-2 counter-cars-who-searched-type-2 + 1
      ]
      if wtp = 0.6 [
        set counter-cars-who-searched-wtp-0.6 counter-cars-who-searched-wtp-0.6 + 1
      ]
      if wtp = 0.7 [
        set counter-cars-who-searched-wtp-0.7 counter-cars-who-searched-wtp-0.7 + 1
      ]
      if wtp = 1 [
        set counter-cars-who-searched-wtp-1 counter-cars-who-searched-wtp-1 + 1
      ]
      if wtp = 1.45 [
        set counter-cars-who-searched-wtp-1.45 counter-cars-who-searched-wtp-1.45 + 1
      ]
      if wtp = 2 [
        set counter-cars-who-searched-wtp-2 counter-cars-who-searched-wtp-2 + 1
      ]
      if wtp = 2.32 [
        set counter-cars-who-searched-wtp-2.32 counter-cars-who-searched-wtp-2.32 + 1
      ]
      set total-search-time-cars-who-searched total-search-time-cars-who-searched + time-searched
    ]
    set total-search-time total-search-time + time-searched
    set total-distance-travelled total-distance-travelled + distance-travelled
  ]
end

to get-parking-spaces-in-radius
  let temp []
  ask destination [
    set temp parking-nodes in-radius parking-radius
  ]
  set parking-spaces-in-parking-radius sort temp
  set parking-spaces-in-parking-radius-copy parking-spaces-in-parking-radius
  if length parking-spaces-in-parking-radius = 0 [
    print "no parking space in specified radius found"
    set no-parking-space-found no-parking-space-found + 1
    set color green
    ;print "couldn't find or afford a parking space"
    set status "leaving"
    if time-searched = 0 [
      if wtp = 0.6 [set counter-cars-not-entering-city-wtp-0.6 counter-cars-not-entering-city-wtp-0.6 + 1]
      if wtp = 0.7 [set counter-cars-not-entering-city-wtp-0.7 counter-cars-not-entering-city-wtp-0.7 + 1]
      if wtp = 1 [set counter-cars-not-entering-city-wtp-1 counter-cars-not-entering-city-wtp-1 + 1]
      if wtp = 1.45 [set counter-cars-not-entering-city-wtp-1.45 counter-cars-not-entering-city-wtp-1.45 + 1]
      if wtp = 2 [set counter-cars-not-entering-city-wtp-2 counter-cars-not-entering-city-wtp-2 + 1]
      if wtp = 2.32 [set counter-cars-not-entering-city-wtp-2.32 counter-cars-not-entering-city-wtp-2.32 + 1]
    ]
    set counter-cars-finished counter-cars-finished + 1
    ifelse agent-type = "1"
        [
          set counter-cars-finished-type-1 counter-cars-finished-type-1 + 1
          set total-search-time-type-1 total-search-time-type-1 + time-searched
          set total-distance-travelled-type-1 total-distance-travelled-type-1 + distance-travelled
        ]
        [
          set counter-cars-finished-type-2 counter-cars-finished-type-2 + 1
          set total-search-time-type-2 total-search-time-type-2 + time-searched
          set total-distance-travelled-type-2 total-distance-travelled-type-2 + distance-travelled
        ]
    if wtp = 0.6 [
      set counter-cars-finished-wtp-0.6 counter-cars-finished-wtp-0.6 + 1
      set total-search-time-wtp-0.6 total-search-time-wtp-0.6 + time-searched
      set total-distance-travelled-wtp-0.6 total-distance-travelled-wtp-0.6 + distance-travelled
    ]
    if wtp = 0.7 [
      set counter-cars-finished-wtp-0.7 counter-cars-finished-wtp-0.7 + 1
      set total-search-time-wtp-0.7 total-search-time-wtp-0.7 + time-searched
      set total-distance-travelled-wtp-0.7 total-distance-travelled-wtp-0.7 + distance-travelled
    ]
    if wtp = 1 [
      set counter-cars-finished-wtp-1 counter-cars-finished-wtp-1 + 1
      set total-search-time-wtp-1 total-search-time-wtp-1 + time-searched
      set total-distance-travelled-wtp-1 total-distance-travelled-wtp-1 + distance-travelled
    ]
    if wtp = 1.45 [
      set counter-cars-finished-wtp-1.45 counter-cars-finished-wtp-1.45 + 1
      set total-search-time-wtp-1.45 total-search-time-wtp-1.45 + time-searched
      set total-distance-travelled-wtp-1.45 total-distance-travelled-wtp-1.45 + distance-travelled
    ]
    if wtp = 2 [
      set counter-cars-finished-wtp-2 counter-cars-finished-wtp-2 + 1
      set total-search-time-wtp-2 total-search-time-wtp-2 + time-searched
      set total-distance-travelled-wtp-2 total-distance-travelled-wtp-2 + distance-travelled
    ]
    if wtp = 2.32 [
      set counter-cars-finished-wtp-2.32 counter-cars-finished-wtp-2.32 + 1
      set total-search-time-wtp-2.32 total-search-time-wtp-2.32 + time-searched
      set total-distance-travelled-wtp-2.32 total-distance-travelled-wtp-2.32 + distance-travelled
    ]
    if time-searched > 0 [
      set counter-cars-who-searched counter-cars-who-searched + 1
      if agent-type = "1" [
        set counter-cars-who-searched-type-1 counter-cars-who-searched-type-1 + 1
      ]
      if agent-type = "2" [
        set counter-cars-who-searched-type-2 counter-cars-who-searched-type-2 + 1
      ]
      if wtp = 0.6 [
        set counter-cars-who-searched-wtp-0.6 counter-cars-who-searched-wtp-0.6 + 1
      ]
      if wtp = 0.7 [
        set counter-cars-who-searched-wtp-0.7 counter-cars-who-searched-wtp-0.7 + 1
      ]
      if wtp = 1 [
        set counter-cars-who-searched-wtp-1 counter-cars-who-searched-wtp-1 + 1
      ]
      if wtp = 1.45 [
        set counter-cars-who-searched-wtp-1.45 counter-cars-who-searched-wtp-1.45 + 1
      ]
      if wtp = 2 [
        set counter-cars-who-searched-wtp-2 counter-cars-who-searched-wtp-2 + 1
      ]
      if wtp = 2.32 [
        set counter-cars-who-searched-wtp-2.32 counter-cars-who-searched-wtp-2.32 + 1
      ]
      set total-search-time-cars-who-searched total-search-time-cars-who-searched + time-searched
    ]
    set total-search-time total-search-time + time-searched
    set total-distance-travelled total-distance-travelled + distance-travelled
  ]
end

to check-parking-requirements-type-1
  let fee-index hours - 1
  let temp max-fee
  let fee-to-pay [item fee-index fees] of parking-space
  ifelse fee-to-pay <= temp and [occupancy] of parking-space < [capacity] of parking-space
  [
    set status "parked"
    set distance-to-destination [nw:weighted-distance-to ([destination] of myself) weight] of parking-space
    set counter-cars-finished counter-cars-finished + 1
    set counter-cars-found-parking-space counter-cars-found-parking-space + 1
    ifelse agent-type = "1"
    [
      set counter-cars-finished-type-1 counter-cars-finished-type-1 + 1
      set counter-cars-found-parking-space-type-1 counter-cars-found-parking-space-type-1 + 1
      set total-search-time-type-1 total-search-time-type-1 + time-searched
      set total-distance-to-destination-type-1 total-distance-to-destination-type-1 + distance-to-destination
      set total-distance-travelled-type-1 total-distance-travelled-type-1 + distance-travelled
    ]
    [
      set counter-cars-finished-type-2 counter-cars-finished-type-2 + 1
      set counter-cars-found-parking-space-type-2 counter-cars-found-parking-space-type-2 + 1
      set total-search-time-type-2 total-search-time-type-2 + time-searched
      set total-distance-to-destination-type-2 total-distance-to-destination-type-2 + distance-to-destination
      set total-distance-travelled-type-2 total-distance-travelled-type-2 + distance-travelled
    ]
    if wtp = 0.6 [
      set counter-cars-finished-wtp-0.6 counter-cars-finished-wtp-0.6 + 1
      set counter-cars-found-parking-space-wtp-0.6 counter-cars-found-parking-space-wtp-0.6 + 1
      set total-search-time-wtp-0.6 total-search-time-wtp-0.6 + time-searched
      set total-distance-to-destination-wtp-0.6 total-distance-to-destination-wtp-0.6 + distance-to-destination
      set total-distance-travelled-wtp-0.6 total-distance-travelled-wtp-0.6 + distance-travelled
    ]
    if wtp = 0.7 [
      set counter-cars-finished-wtp-0.7 counter-cars-finished-wtp-0.7 + 1
      set counter-cars-found-parking-space-wtp-0.7 counter-cars-found-parking-space-wtp-0.7 + 1
      set total-search-time-wtp-0.7 total-search-time-wtp-0.7 + time-searched
      set total-distance-to-destination-wtp-0.7 total-distance-to-destination-wtp-0.7 + distance-to-destination
      set total-distance-travelled-wtp-0.7 total-distance-travelled-wtp-0.7 + distance-travelled
    ]
    if wtp = 1 [
      set counter-cars-finished-wtp-1 counter-cars-finished-wtp-1 + 1
      set counter-cars-found-parking-space-wtp-1 counter-cars-found-parking-space-wtp-1 + 1
      set total-search-time-wtp-1 total-search-time-wtp-1 + time-searched
      set total-distance-to-destination-wtp-1 total-distance-to-destination-wtp-1 + distance-to-destination
      set total-distance-travelled-wtp-1 total-distance-travelled-wtp-1 + distance-travelled
    ]
    if wtp = 1.45 [
      set counter-cars-finished-wtp-1.45 counter-cars-finished-wtp-1.45 + 1
      set counter-cars-found-parking-space-wtp-1.45 counter-cars-found-parking-space-wtp-1.45 + 1
      set total-search-time-wtp-1.45 total-search-time-wtp-1.45 + time-searched
      set total-distance-to-destination-wtp-1.45 total-distance-to-destination-wtp-1.45 + distance-to-destination
      set total-distance-travelled-wtp-1.45 total-distance-travelled-wtp-1.45 + distance-travelled
    ]
    if wtp = 2 [
      set counter-cars-finished-wtp-2 counter-cars-finished-wtp-2 + 1
      set counter-cars-found-parking-space-wtp-2 counter-cars-found-parking-space-wtp-2 + 1
      set total-search-time-wtp-2 total-search-time-wtp-2 + time-searched
      set total-distance-to-destination-wtp-2 total-distance-to-destination-wtp-2 + distance-to-destination
      set total-distance-travelled-wtp-2 total-distance-travelled-wtp-2 + distance-travelled
    ]
    if wtp = 2.32 [
      set counter-cars-finished-wtp-2.32 counter-cars-finished-wtp-2.32 + 1
      set counter-cars-found-parking-space-wtp-2.32 counter-cars-found-parking-space-wtp-2.32 + 1
      set total-search-time-wtp-2.32 total-search-time-wtp-2.32 + time-searched
      set total-distance-to-destination-wtp-2.32 total-distance-to-destination-wtp-2.32 + distance-to-destination
      set total-distance-travelled-wtp-2.32 total-distance-travelled-wtp-2.32 + distance-travelled
    ]
    if time-searched > 0 [
      set counter-cars-who-searched counter-cars-who-searched + 1
      if agent-type = "1" [
        set counter-cars-who-searched-type-1 counter-cars-who-searched-type-1 + 1
      ]
      if agent-type = "2" [
        set counter-cars-who-searched-type-2 counter-cars-who-searched-type-2 + 1
      ]
      if wtp = 0.6 [
        set counter-cars-who-searched-wtp-0.6 counter-cars-who-searched-wtp-0.6 + 1
      ]
      if wtp = 0.7 [
        set counter-cars-who-searched-wtp-0.7 counter-cars-who-searched-wtp-0.7 + 1
      ]
      if wtp = 1 [
        set counter-cars-who-searched-wtp-1 counter-cars-who-searched-wtp-1 + 1
      ]
      if wtp = 1.45 [
        set counter-cars-who-searched-wtp-1.45 counter-cars-who-searched-wtp-1.45 + 1
      ]
      if wtp = 2 [
        set counter-cars-who-searched-wtp-2 counter-cars-who-searched-wtp-2 + 1
      ]
      if wtp = 2.32 [
        set counter-cars-who-searched-wtp-2.32 counter-cars-who-searched-wtp-2.32 + 1
      ]
      set total-search-time-cars-who-searched total-search-time-cars-who-searched + time-searched
      set counter-cars-who-searched-successfully counter-cars-who-searched-successfully + 1
      set total-search-time-cars-who-searched-successfully total-search-time-cars-who-searched-successfully + time-searched
    ]
    set total-search-time total-search-time + time-searched
    set total-distance-to-destination total-distance-to-destination + distance-to-destination
    set total-distance-travelled total-distance-travelled + distance-travelled
    set searching false
    ask parking-space [
      set occupancy occupancy + 1
      if dynamic-pricing = true [
        apply-dynamic-pricing
      ]
    ]
    set hidden? true
  ]
  [
    print "Parking-space got full or to expensive before i could reach it. Looking for a new one."
    set total-failed-attempts total-failed-attempts + 1
    if agent-type = "1" [ set total-failed-attempts-type-1 total-failed-attempts-type-1 + 1 ]
    if agent-type = "2" [ set total-failed-attempts-type-2 total-failed-attempts-type-2 + 1 ]
    if wtp = 0.6 [ set total-failed-attempts-wtp-0.6 total-failed-attempts-wtp-0.6 + 1 ]
    if wtp = 0.7 [ set total-failed-attempts-wtp-0.7 total-failed-attempts-wtp-0.7 + 1 ]
    if wtp = 1 [ set total-failed-attempts-wtp-1 total-failed-attempts-wtp-1 + 1 ]
    if wtp = 1.45 [ set total-failed-attempts-wtp-1.45 total-failed-attempts-wtp-1.45 + 1 ]
    if wtp = 2 [ set total-failed-attempts-wtp-2 total-failed-attempts-wtp-2 + 1 ]
    if wtp = 2.32 [ set total-failed-attempts-wtp-2.32 total-failed-attempts-wtp-2.32 + 1 ]
    set parking-spaces-in-parking-radius remove parking-space parking-spaces-in-parking-radius
    ifelse length parking-spaces-in-parking-radius > 0
    [
      select-parking-space
      set searching true
    ]
    [
      set parking-spaces-in-parking-radius parking-spaces-in-parking-radius-copy
      select-parking-space
      set searching true
    ]
  ]
end

to check-parking-requirements-type-2
  let fee-index hours - 1
  let temp max-fee
  let fee-to-pay [item fee-index fees] of parking-space
  ifelse fee-to-pay <= temp and [occupancy] of parking-space < [capacity] of parking-space
  [
    set status "parked"
    set distance-to-destination [nw:weighted-distance-to ([destination] of myself) weight] of parking-space
    set counter-cars-finished counter-cars-finished + 1
    set counter-cars-found-parking-space counter-cars-found-parking-space + 1
    ifelse agent-type = "1"
    [
      set counter-cars-finished-type-1 counter-cars-finished-type-1 + 1
      set counter-cars-found-parking-space-type-1 counter-cars-found-parking-space-type-1 + 1
      set total-search-time-type-1 total-search-time-type-1 + time-searched
      set total-distance-to-destination-type-1 total-distance-to-destination-type-1 + distance-to-destination
      set total-distance-travelled-type-1 total-distance-travelled-type-1 + distance-travelled
    ]
    [
      set counter-cars-finished-type-2 counter-cars-finished-type-2 + 1
      set counter-cars-found-parking-space-type-2 counter-cars-found-parking-space-type-2 + 1
      set total-search-time-type-2 total-search-time-type-2 + time-searched
      set total-distance-to-destination-type-2 total-distance-to-destination-type-2 + distance-to-destination
      set total-distance-travelled-type-2 total-distance-travelled-type-2 + distance-travelled
    ]
    if wtp = 0.6 [
      set counter-cars-finished-wtp-0.6 counter-cars-finished-wtp-0.6 + 1
      set counter-cars-found-parking-space-wtp-0.6 counter-cars-found-parking-space-wtp-0.6 + 1
      set total-search-time-wtp-0.6 total-search-time-wtp-0.6 + time-searched
      set total-distance-to-destination-wtp-0.6 total-distance-to-destination-wtp-0.6 + distance-to-destination
      set total-distance-travelled-wtp-0.6 total-distance-travelled-wtp-0.6 + distance-travelled
    ]
    if wtp = 0.7 [
      set counter-cars-finished-wtp-0.7 counter-cars-finished-wtp-0.7 + 1
      set counter-cars-found-parking-space-wtp-0.7 counter-cars-found-parking-space-wtp-0.7 + 1
      set total-search-time-wtp-0.7 total-search-time-wtp-0.7 + time-searched
      set total-distance-to-destination-wtp-0.7 total-distance-to-destination-wtp-0.7 + distance-to-destination
      set total-distance-travelled-wtp-0.7 total-distance-travelled-wtp-0.7 + distance-travelled
    ]
    if wtp = 1 [
      set counter-cars-finished-wtp-1 counter-cars-finished-wtp-1 + 1
      set counter-cars-found-parking-space-wtp-1 counter-cars-found-parking-space-wtp-1 + 1
      set total-search-time-wtp-1 total-search-time-wtp-1 + time-searched
      set total-distance-to-destination-wtp-1 total-distance-to-destination-wtp-1 + distance-to-destination
      set total-distance-travelled-wtp-1 total-distance-travelled-wtp-1 + distance-travelled
    ]
    if wtp = 1.45 [
      set counter-cars-finished-wtp-1.45 counter-cars-finished-wtp-1.45 + 1
      set counter-cars-found-parking-space-wtp-1.45 counter-cars-found-parking-space-wtp-1.45 + 1
      set total-search-time-wtp-1.45 total-search-time-wtp-1.45 + time-searched
      set total-distance-to-destination-wtp-1.45 total-distance-to-destination-wtp-1.45 + distance-to-destination
      set total-distance-travelled-wtp-1.45 total-distance-travelled-wtp-1.45 + distance-travelled
    ]
    if wtp = 2 [
      set counter-cars-finished-wtp-2 counter-cars-finished-wtp-2 + 1
      set counter-cars-found-parking-space-wtp-2 counter-cars-found-parking-space-wtp-2 + 1
      set total-search-time-wtp-2 total-search-time-wtp-2 + time-searched
      set total-distance-to-destination-wtp-2 total-distance-to-destination-wtp-2 + distance-to-destination
      set total-distance-travelled-wtp-2 total-distance-travelled-wtp-2 + distance-travelled
    ]
    if wtp = 2.32 [
      set counter-cars-finished-wtp-2.32 counter-cars-finished-wtp-2.32 + 1
      set counter-cars-found-parking-space-wtp-2.32 counter-cars-found-parking-space-wtp-2.32 + 1
      set total-search-time-wtp-2.32 total-search-time-wtp-2.32 + time-searched
      set total-distance-to-destination-wtp-2.32 total-distance-to-destination-wtp-2.32 + distance-to-destination
      set total-distance-travelled-wtp-2.32 total-distance-travelled-wtp-2.32 + distance-travelled
    ]
    if time-searched > 0 [
      set counter-cars-who-searched counter-cars-who-searched + 1
      if agent-type = "1" [
        set counter-cars-who-searched-type-1 counter-cars-who-searched-type-1 + 1
      ]
      if agent-type = "2" [
        set counter-cars-who-searched-type-2 counter-cars-who-searched-type-2 + 1
      ]
      if wtp = 0.6 [
        set counter-cars-who-searched-wtp-0.6 counter-cars-who-searched-wtp-0.6 + 1
      ]
      if wtp = 0.7 [
        set counter-cars-who-searched-wtp-0.7 counter-cars-who-searched-wtp-0.7 + 1
      ]
      if wtp = 1 [
        set counter-cars-who-searched-wtp-1 counter-cars-who-searched-wtp-1 + 1
      ]
      if wtp = 1.45 [
        set counter-cars-who-searched-wtp-1.45 counter-cars-who-searched-wtp-1.45 + 1
      ]
      if wtp = 2 [
        set counter-cars-who-searched-wtp-2 counter-cars-who-searched-wtp-2 + 1
      ]
      if wtp = 2.32 [
        set counter-cars-who-searched-wtp-2.32 counter-cars-who-searched-wtp-2.32 + 1
      ]
      set total-search-time-cars-who-searched total-search-time-cars-who-searched + time-searched
      set counter-cars-who-searched-successfully counter-cars-who-searched-successfully + 1
      set total-search-time-cars-who-searched-successfully total-search-time-cars-who-searched-successfully + time-searched
    ]
    set total-search-time total-search-time + time-searched
    set total-distance-to-destination total-distance-to-destination + distance-to-destination
    set total-distance-travelled total-distance-travelled + distance-travelled
    set searching false
    ask parking-space [
      set occupancy occupancy + 1
      if dynamic-pricing = true [
        apply-dynamic-pricing
      ]
    ]
    set hidden? true
  ]
  [
    set total-failed-attempts total-failed-attempts + 1
    if agent-type = "1" [ set total-failed-attempts-type-1 total-failed-attempts-type-1 + 1 ]
    if agent-type = "2" [ set total-failed-attempts-type-2 total-failed-attempts-type-2 + 1 ]
    if wtp = 0.6 [ set total-failed-attempts-wtp-0.6 total-failed-attempts-wtp-0.6 + 1 ]
    if wtp = 0.7 [ set total-failed-attempts-wtp-0.7 total-failed-attempts-wtp-0.7 + 1 ]
    if wtp = 1 [ set total-failed-attempts-wtp-1 total-failed-attempts-wtp-1 + 1 ]
    if wtp = 1.45 [ set total-failed-attempts-wtp-1.45 total-failed-attempts-wtp-1.45 + 1 ]
    if wtp = 2 [ set total-failed-attempts-wtp-2 total-failed-attempts-wtp-2 + 1 ]
    if wtp = 2.32 [ set total-failed-attempts-wtp-2.32 total-failed-attempts-wtp-2.32 + 1 ]
    set parking-spaces-in-parking-radius remove parking-space parking-spaces-in-parking-radius
    ifelse length parking-spaces-in-parking-radius > 0
    [
      get-closest-parking-space-type-2
      set searching true
    ]
    [
      set parking-spaces-in-parking-radius parking-spaces-in-parking-radius-copy
      get-closest-parking-space-type-2
      set searching true
    ]
  ]
end

to get-closest-parking-space-type-1
  let min-distance 1000
  foreach most-affordable-parking-space [n ->
    if [nw:weighted-distance-to ([destination] of myself) weight] of n = false [
      user-message (word "There is no path to " n " . Please check if the parking-node is connected to the network.")
      show n
      ask n [
        set hidden? false
        set size 20
        set color blue
      ]
    ]
    if [nw:weighted-distance-to ([destination] of myself) weight] of n < min-distance [
      set min-distance [nw:weighted-distance-to ([destination] of myself) weight] of n
      set closest-parking-space n

    ]
  ]
  ; catch case when both parking spaces have equal travel distance to
  if closest-parking-space = 0 [
    set closest-parking-space item 0 most-affordable-parking-space
  ]
end

to get-closest-parking-space-type-2
  let min-distance 1000
  foreach parking-spaces-in-parking-radius [n ->
    if [nw:weighted-distance-to ([destination] of myself) weight] of n = false [
      user-message (word "There is no path to " n " . Please check if the parking-node is connected to the network.")
      show n
      ask n [
        set hidden? false
        set size 20
        set color blue
      ]
    ]
    if [nw:weighted-distance-to ([destination] of myself) weight] of n < min-distance [
      set min-distance [nw:weighted-distance-to ([destination] of myself) weight] of n
      set parking-space n
    ]
  ]
end

to select-destination
  set destination one-of nodes
end

to check-collision
  if status = "parked" [
    print "danger"
  ]
  ifelse not any? cars-on patch-ahead 1
  [
    set status "driving"
  ]
  [
    let current-heading heading
    let driving-cars cars-on patch-ahead 1
    ask driving-cars [
      ifelse heading = current-heading and self != myself
      [ set status "waiting" ]
      [ set status "driving" ]
    ]
  ]
end

to move
  ; parking-space of myself is needed to reference the variable parking-space of the current person, if myself is
      ; missing the program tries to access the variable parking-space of a node (which does not exist)
  let next-node 0
  if current-location != parking-space and status != "parked" [
    set next-node item 1 [nw:turtles-on-weighted-path-to ([parking-space] of myself) weight] of current-location
    face next-node
    ;check-collision
  ]
  if current-location != parking-space and status != "parked"[
    let temp-speed 10
    ask current-location [
      ask link-with next-node [
        if speed-limit = nobody or speed-limit = 0 [
          set speed-limit 50 ]
        set temp-speed speed-limit
      ]
    ]
    set allowed-travel-distance 0.278 * temp-speed * 0.317; * 1
    ; 1km/h = 0.278 m/s
    ; temp-speed contains speed-limit as integer (like 50)
    ; 1m = 0.317 Netlogo-Units
    ; 1 = 1s -> distance = speed (0.278 * temp-speed * 0.317) * time (1)
    while [allowed-travel-distance != 0 and current-second != 1 and status != "parked" ]
    [
      set distance-to-next-node [distance myself] of next-node
      if distance-to-next-node > allowed-travel-distance [
        face next-node
        let temp allowed-travel-distance
        while [ allowed-travel-distance != 0 ]
        [
          ;check-collision
          ifelse allowed-travel-distance > 1
          [
            fd 1
            set allowed-travel-distance allowed-travel-distance - 1
          ]
          [
            fd allowed-travel-distance
            set allowed-travel-distance 0
          ]
        ]
        if searching = true [
          set total-distance-searched total-distance-searched + temp
          ifelse agent-type = "1"
          [ set total-distance-searched-type-1 total-distance-searched-type-1 + temp ]
          [ set total-distance-searched-type-2 total-distance-searched-type-2 + temp ]
          if wtp = 0.6 [
            set total-distance-searched-wtp-0.6 total-distance-searched-wtp-0.6 + temp
          ]
          if wtp = 0.7 [
            set total-distance-searched-wtp-0.7 total-distance-searched-wtp-0.7 + temp
          ]
          if wtp = 1 [
            set total-distance-searched-wtp-1 total-distance-searched-wtp-1 + temp
          ]
          if wtp = 1.45 [
            set total-distance-searched-wtp-1.45 total-distance-searched-wtp-1.45 + temp
          ]
          if wtp = 2 [
            set total-distance-searched-wtp-2 total-distance-searched-wtp-2 + temp
          ]
          if wtp = 2.32 [
            set total-distance-searched-wtp-2.32 total-distance-searched-wtp-2.32 + temp
          ]
        ]
        set distance-travelled distance-travelled + temp
        set distance-to-next-node distance-to-next-node - temp
        set allowed-travel-distance 0
        set current-second 1
      ]
      if distance-to-next-node = allowed-travel-distance [
        face next-node
        let temp allowed-travel-distance
        while [ allowed-travel-distance != 0 ]
        [
          ;check-collision
          ifelse allowed-travel-distance > 1
          [
            fd 1
            set allowed-travel-distance allowed-travel-distance - 1
          ]
          [
            fd allowed-travel-distance
            set allowed-travel-distance 0
          ]
        ]
          if searching = true [
          set total-distance-searched total-distance-searched + temp
          ifelse agent-type = "1"
          [ set total-distance-searched-type-1 total-distance-searched-type-1 + temp ]
          [ set total-distance-searched-type-2 total-distance-searched-type-2 + temp ]
          if wtp = 0.6 [
            set total-distance-searched-wtp-0.6 total-distance-searched-wtp-0.6 + temp
          ]
          if wtp = 0.7 [
            set total-distance-searched-wtp-0.7 total-distance-searched-wtp-0.7 + temp
          ]
          if wtp = 1 [
            set total-distance-searched-wtp-1 total-distance-searched-wtp-1 + temp
          ]
          if wtp = 1.45 [
            set total-distance-searched-wtp-1.45 total-distance-searched-wtp-1.45 + temp
          ]
          if wtp = 2 [
            set total-distance-searched-wtp-2 total-distance-searched-wtp-2 + temp
          ]
          if wtp = 2.32 [
            set total-distance-searched-wtp-2.32 total-distance-searched-wtp-2.32 + temp
          ]
        ]
        set distance-travelled distance-travelled + temp
        set allowed-travel-distance 0
        set current-second 1
        set current-location next-node
        if current-location = parking-space and agent-type = "1" [
          check-parking-requirements-type-1
        ]
      ]
      if distance-to-next-node < allowed-travel-distance [
        let temp-distance-to-next-node distance-to-next-node
        face next-node
        while [ temp-distance-to-next-node != 0 ]
        [
          ;check-collision
          ifelse temp-distance-to-next-node > 1
          [
            fd 1
            set temp-distance-to-next-node temp-distance-to-next-node - 1
          ]
          [
            fd temp-distance-to-next-node
            set allowed-travel-distance allowed-travel-distance - temp-distance-to-next-node
            set temp-distance-to-next-node 0
          ]
        ]
        if searching = true [
          set total-distance-searched total-distance-searched + distance-to-next-node
          ifelse agent-type = "1"
          [ set total-distance-searched-type-1 total-distance-searched-type-1 + distance-to-next-node ]
          [ set total-distance-searched-type-2 total-distance-searched-type-2 + distance-to-next-node ]
          if wtp = 0.6 [
            set total-distance-searched-wtp-0.6 total-distance-searched-wtp-0.6 + distance-to-next-node
          ]
          if wtp = 0.7 [
            set total-distance-searched-wtp-0.7 total-distance-searched-wtp-0.7 + distance-to-next-node
          ]
          if wtp = 1 [
            set total-distance-searched-wtp-1 total-distance-searched-wtp-1 + distance-to-next-node
          ]
          if wtp = 1.45 [
            set total-distance-searched-wtp-1.45 total-distance-searched-wtp-1.45 + distance-to-next-node
          ]
          if wtp = 2 [
            set total-distance-searched-wtp-2 total-distance-searched-wtp-2 + distance-to-next-node
          ]
          if wtp = 2.32 [
            set total-distance-searched-wtp-2.32 total-distance-searched-wtp-2.32 + distance-to-next-node
          ]
        ]
        set distance-travelled distance-travelled + distance-to-next-node
        set current-location next-node
        if current-location != parking-space [
          set next-node item 1 [nw:turtles-on-weighted-path-to ([parking-space] of myself) weight] of current-location
          set current-second current-second + (distance-to-next-node / (0.278 * temp-speed * 0.317))
          ask current-location [
            ask link-with next-node [
              if speed-limit = nobody or speed-limit = 0 [
                set speed-limit 50 ]
              set temp-speed speed-limit
            ]
          ]
          set allowed-travel-distance 0.278 * temp-speed * 0.317 * (1 - current-second)
        ]
        if current-location = parking-space [
          set current-second 1
          set allowed-travel-distance 0
          if agent-type = "1" [
            check-parking-requirements-type-1
          ]
        ]
      ]
    ]
  set current-second 0
  set passed-seconds passed-seconds + 1
  ]
end

to leave-city
  if current-location = spawn [
    die
  ]
  let next-node 0
  if current-location != spawn and status = "leaving" [
    set next-node item 1 [nw:turtles-on-weighted-path-to ([spawn] of myself) weight] of current-location
    face next-node
  ]
  if current-location != spawn and status = "leaving"[
    let temp-speed 10
    ask current-location [
      ask link-with next-node [
        if speed-limit = nobody or speed-limit = 0 [
          set speed-limit 50 ]
        set temp-speed speed-limit
      ]
    ]
    set allowed-travel-distance 0.278 * temp-speed * 0.317
    while [allowed-travel-distance != 0 and current-second != 1 and status = "leaving" ]
    [
      set distance-to-next-node [distance myself] of next-node
      if distance-to-next-node > allowed-travel-distance [
        face next-node
        let temp allowed-travel-distance
        while [ allowed-travel-distance != 0 ]
        [
          ifelse allowed-travel-distance > 1
          [
            fd 1
            set allowed-travel-distance allowed-travel-distance - 1
          ]
          [
            fd allowed-travel-distance
            set allowed-travel-distance 0
          ]
        ]
        ;set total-distance-travelled total-distance-travelled + temp
        set distance-to-next-node distance-to-next-node - temp
        set allowed-travel-distance 0
        set current-second 1
      ]
      if distance-to-next-node = allowed-travel-distance [
        face next-node
        let temp allowed-travel-distance
        while [ allowed-travel-distance != 0 ]
        [
          ifelse allowed-travel-distance > 1
          [
            fd 1
            set allowed-travel-distance allowed-travel-distance - 1
          ]
          [
            fd allowed-travel-distance
            set allowed-travel-distance 0
          ]
        ]
        ;set total-distance-travelled total-distance-travelled + temp
        set allowed-travel-distance 0
        set current-second 1
        set current-location next-node
        if current-location = spawn [
          die
        ]
      ]
      if distance-to-next-node < allowed-travel-distance [
        let temp-distance-to-next-node distance-to-next-node
        face next-node
        while [ temp-distance-to-next-node != 0 ]
        [
          ifelse temp-distance-to-next-node > 1
          [
            fd 1
            set temp-distance-to-next-node temp-distance-to-next-node - 1
          ]
          [
            fd temp-distance-to-next-node
            set allowed-travel-distance allowed-travel-distance - temp-distance-to-next-node
            set temp-distance-to-next-node 0
          ]
        ]
        ;set total-distance-travelled total-distance-travelled + distance-to-next-node
        set current-location next-node
        if current-location != spawn [
          set next-node item 1 [nw:turtles-on-weighted-path-to ([spawn] of myself) weight] of current-location
          set current-second current-second + (distance-to-next-node / (0.278 * temp-speed * 0.317))
          ask current-location [
            ask link-with next-node [
              if speed-limit = nobody or speed-limit = 0 [
                set speed-limit 50 ]
              set temp-speed speed-limit
            ]
          ]
          set allowed-travel-distance 0.278 * temp-speed * 0.317 * (1 - current-second)
        ]
        if current-location = spawn [
          set current-second 1
          set allowed-travel-distance 0
          die
        ]
      ]
    ]
  set current-second 0
  set passed-seconds passed-seconds + 1
  ]
end

to set-spawn-nodes
  ask node 115 [
    set breed spawn-nodes
  ]
  ask node 120 [
    set breed spawn-nodes
  ]
  ask node 1215 [
    set breed spawn-nodes
  ]
  ask node 1293 [
    set breed spawn-nodes
  ]
  ask node 379 [
    set breed spawn-nodes
  ]
  ask node 1428 [
    set breed spawn-nodes
  ]
  ask node 781 [
    set breed spawn-nodes
  ]
  ask node 252 [
    set breed spawn-nodes
  ]
  ask node 1766 [
    set breed spawn-nodes
  ]
  ask node 1208 [
    set breed spawn-nodes
  ]
  ask node 228 [
    set breed spawn-nodes
  ]
  ask node 940 [
    set breed spawn-nodes
  ]
  ask node 975 [
    set breed spawn-nodes
  ]
  ask node 306 [
    set breed spawn-nodes
  ]
  ask node 1560 [
    set breed spawn-nodes
  ]
  ask node 980 [
    set breed spawn-nodes
  ]
  ask node 361 [
    set breed spawn-nodes
  ]
  ask spawn-nodes [
    set shape "circle"
    set size 7
    set color green
    set hidden? false
  ]
end

to set-parking-nodes
  ask node 1182 [
    set breed parking-nodes
    set name "H6"
    set capacity 271
    set original-fees [1.2 2.4 3.6 4.8 6 6 6 6 6]
  ]
  ask node 1476 [
    set breed parking-nodes
    set name "K1"
    set capacity 283
    set original-fees [1.5 3 4 4.5 5.5 6.5 7.5 8.5 8.5]
  ]
  ask node 893 [
    set breed parking-nodes
    set name "U2"
    set capacity 190
    set original-fees [1.4 2.8 4.2 5.6 7 7 7 7 7]
  ]
  ask node 613 [
    set breed parking-nodes
    set name "G1"
    set capacity 337
    set original-fees [2 4 6 8 10 10 10 10 10]
  ]
  ask node 1661 [
    set breed parking-nodes
    set name "R5"
    set capacity 505
    set original-fees [2.2 4.5 6.5 9 11 13 15 15 15]
  ]
  ask node 1780 [
    set breed parking-nodes
    set name "S6"
    set capacity 200
    set original-fees [1.9 3.8 5.5 6.5 7.5 8.5 9.5 10.5 11.5]
  ]
  ask node 1629 [
    set breed parking-nodes
    set name "Q6/Q7"
    set capacity 1300
    set original-fees [2.2 4.5 6.5 9 11 13 15 15 15]
  ]
  ask node 1779 [
    set breed parking-nodes
    set name "N7 Galeria Kaufhof"
    set capacity 538
    set original-fees [2 4 6 8 10 12 14 16 18]
  ]
  ask node 1402 [
    set breed parking-nodes
    set name "N7 Cinemaxx"
    set capacity 201
    set original-fees [3 5.5 8 10.5 11.5 12.5 13.5 14.5 15.5]
  ]
  ask node 444 [
    set breed parking-nodes
    set name "N6 Komfort"
    set capacity 201
    set original-fees [2.2 4.5 6.8 8 9 10 11 12 12]
  ]
  ask node 1542 [
    set breed parking-nodes
    set name "N6 Standard"
    set capacity 298
    set original-fees [2 4 6 7 8 9 10 10 10]
  ]
  ask node 316 [
    set breed parking-nodes
    set name "M4a"
    set capacity 68
    set original-fees [2 4 6 7 8 9 9 9 9]
  ]
  ask node 602 [
    set breed parking-nodes
    set name "N2"
    set capacity 286
    set original-fees [2 4 6 7 8 9 10 10 10]
  ]
  ask node 902 [
    set breed parking-nodes
    set name "N1"
    set capacity 441
    set original-fees [2 4 6 7 8 9 10 10 10]
  ]
  ask node 1781 [
    set breed parking-nodes
    set name "A1"
    set capacity 163
    set original-fees [3 3 3 5 5 5 5 5 5]
  ]
  ask node 913 [
    set breed parking-nodes
    set name "C1"
    set capacity 211
    set original-fees [1.5 3 4.5 5.5 6.5 7.5 8.5 8.5 8.5]
  ]
  ask node 1777 [
    set breed parking-nodes
    set name "D3"
    set capacity 378
    set original-fees [1.5 3 4.5 5.5 6.5 7.5 8.5 8.5 8.5]
  ]
  ask node 1778 [
    set breed parking-nodes
    set name "D5"
    set capacity 365
    set original-fees [1.4 2.8 4.2 5.6 7 7 7 7 7]
  ]
  ask parking-nodes [
    set shape "flag"
    set size 7
    set color black
    set hidden? false
    set fees []
    ifelse dynamic-pricing = true
    [ apply-dynamic-pricing ]
    [ set fees original-fees]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
10
10
919
620
-1
-1
1.0
1
25
1
1
1
0
0
0
1
-450
450
-300
300
1
1
1
ticks
30.0

BUTTON
13
633
76
666
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
91
633
154
666
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
12
679
218
712
parking-radius
parking-radius
0
300
285.3
.1
1
Netlogo-Units
HORIZONTAL

PLOT
254
932
579
1141
Anzahl der Autos
Zeit (in s)
Autos
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"gesamt" 1.0 0 -16777216 true "" "plot count cars"
"fahrende Autos" 1.0 0 -5825686 true "" "plot count cars with [status = \"driving\" or status = \"leaving\"]"
"geparkte Autos" 1.0 0 -13345367 true "" "plot count cars with [status = \"parked\"]"
"keinen Platz gefunden" 1.0 0 -2674135 true "" "plot no-parking-space-found"
"erzeugte Autos" 1.0 0 -13840069 true "" "plot counter-spawned-cars"

SLIDER
12
722
184
755
amount-app-user
amount-app-user
0
100
0.0
10
1
%
HORIZONTAL

PLOT
973
625
1431
954
Parkplatzbelegung
Zeit (in s)
Belegung (in %)
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"H6" 1.0 0 -7500403 true "" "ask parking-node 1182 [ plot occupancy / capacity * 100 ]"
"K1" 1.0 0 -2674135 true "" "ask parking-node 1476 [ plot occupancy / capacity * 100 ]"
"U2" 1.0 0 -955883 true "" "ask parking-node 893 [ plot occupancy / capacity * 100 ]"
"G1" 1.0 0 -6459832 true "" "ask parking-node 613 [ plot occupancy / capacity * 100 ]"
"R5" 1.0 0 -1184463 true "" "ask parking-node 1661 [ plot occupancy / capacity * 100 ]"
"S6" 1.0 0 -10899396 true "" "ask parking-node 1780 [ plot occupancy / capacity * 100 ]"
"Q6/Q7" 1.0 0 -13840069 true "" "ask parking-node 1629 [ plot occupancy / capacity * 100 ]"
"N7 Galeria Kaufhof" 1.0 0 -14835848 true "" "ask parking-node 1779 [ plot occupancy / capacity * 100 ]"
"N7 Cinemaxx" 1.0 0 -11221820 true "" "ask parking-node 1402 [ plot occupancy / capacity * 100 ]"
"N6 Komfort" 1.0 0 -13791810 true "" "ask parking-node 444 [ plot occupancy / capacity * 100 ]"
"N6 Standard" 1.0 0 -13345367 true "" "ask parking-node 1542 [ plot occupancy / capacity * 100 ]"
"M4a" 1.0 0 -8630108 true "" "ask parking-node 316 [ plot occupancy / capacity * 100 ]"
"N2" 1.0 0 -5825686 true "" "ask parking-node 602 [ plot occupancy / capacity * 100 ]"
"N1" 1.0 0 -2064490 true "" "ask parking-node 902 [ plot occupancy / capacity * 100 ]"
"A1" 1.0 0 -10603201 true "" "ask parking-node 1781 [ plot occupancy / capacity * 100 ]"
"C1" 1.0 0 -4528153 true "" "ask parking-node 913 [ plot occupancy / capacity * 100 ]"
"D3" 1.0 0 -3026479 true "" "ask parking-node 1777 [ plot occupancy / capacity * 100 ]"
"D5" 1.0 0 -865067 true "" "ask parking-node 1778 [ plot occupancy / capacity * 100 ]"

SWITCH
12
765
153
798
dynamic-pricing
dynamic-pricing
1
1
-1000

PLOT
254
633
685
926
durchschnittliche Suchdauer
Zeit (in s)
Suchdauer (in s)
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"gesamt" 1.0 0 -16777216 true "" "ifelse ticks > 0 and counter-cars-finished > 0\n[plot total-search-time / counter-cars-finished]\n[plot 0]"
"Typ 1" 1.0 0 -2674135 true "" "ifelse ticks > 0 and counter-cars-finished-type-1 > 0\n[plot total-search-time-type-1 / counter-cars-finished-type-1]\n[plot 0]"
"Typ 2" 1.0 0 -13345367 true "" "ifelse ticks > 0 and counter-cars-finished-type-2 > 0\n[plot total-search-time-type-2 / counter-cars-finished-type-2]\n[plot 0]"
"Schicht 0,6" 1.0 0 -612749 true "" "ifelse ticks > 0 and counter-cars-finished-wtp-0.6 > 0\n[plot total-search-time-wtp-0.6 / counter-cars-finished-wtp-0.6]\n[plot 0]"
"Schicht 0,7" 1.0 0 -6459832 true "" "ifelse ticks > 0 and counter-cars-finished-wtp-0.7 > 0\n[plot total-search-time-wtp-0.7 / counter-cars-finished-wtp-0.7]\n[plot 0]"
"Schicht 1" 1.0 0 -8630108 true "" "ifelse ticks > 0 and counter-cars-finished-wtp-1 > 0\n[plot total-search-time-wtp-1 / counter-cars-finished-wtp-1]\n[plot 0]"
"Schicht 1,45" 1.0 0 -2064490 true "" "ifelse ticks > 0 and counter-cars-finished-wtp-1.45 > 0\n[plot total-search-time-wtp-1.45 / counter-cars-finished-wtp-1.45]\n[plot 0]"
"Schicht 2" 1.0 0 -13840069 true "" "ifelse ticks > 0 and counter-cars-finished-wtp-2 > 0\n[plot total-search-time-wtp-2 / counter-cars-finished-wtp-2]\n[plot 0]"
"Schicht 2,32" 1.0 0 -7500403 true "" "ifelse ticks > 0 and counter-cars-finished-wtp-2.32 > 0\n[plot total-search-time-wtp-2.32 / counter-cars-finished-wtp-2.32]\n[plot 0]"

MONITOR
1443
625
1564
670
average occupancy
total-occupancy / total-parking-spaces * 100
1
1
11

PLOT
595
933
943
1144
Suchdauer Details
Zeit (in s)
Suchdauer (in s)
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Suchdauer Suchender" 1.0 0 -16777216 true "" "ifelse counter-cars-who-searched > 0 \n[plot total-search-time-cars-who-searched / counter-cars-who-searched]\n[plot 0]"
"Suchdauer Findender" 1.0 0 -13840069 true "" "ifelse counter-cars-who-searched-successfully > 0\n[plot total-search-time-cars-who-searched-successfully / counter-cars-who-searched-successfully]\n[plot 0]"

MONITOR
253
1200
432
1245
NIL
counter-cars-finished-wtp-0.6
17
1
11

MONITOR
253
1148
482
1193
NIL
counter-cars-not-entering-city-wtp-0.6
17
1
11

MONITOR
499
1148
728
1193
NIL
counter-cars-not-entering-city-wtp-0.7
17
1
11

MONITOR
499
1199
678
1244
NIL
counter-cars-finished-wtp-0.7
17
1
11

MONITOR
746
1149
964
1194
NIL
counter-cars-not-entering-city-wtp-1
17
1
11

MONITOR
982
1149
1218
1194
NIL
counter-cars-not-entering-city-wtp-1.45
17
1
11

MONITOR
1232
1149
1450
1194
NIL
counter-cars-not-entering-city-wtp-2
17
1
11

MONITOR
1464
1149
1700
1194
NIL
counter-cars-not-entering-city-wtp-2.32
17
1
11

MONITOR
746
1199
913
1244
NIL
counter-cars-finished-wtp-1
17
1
11

MONITOR
982
1198
1168
1243
NIL
counter-cars-finished-wtp-1.45
17
1
11

MONITOR
1232
1199
1399
1244
NIL
counter-cars-finished-wtp-2
17
1
11

MONITOR
1464
1199
1650
1244
NIL
counter-cars-finished-wtp-2.32
17
1
11

MONITOR
257
1635
445
1680
average distance to destination
total-distance-to-destination / counter-cars-found-parking-space
1
1
11

TEXTBOX
253
1294
565
1332
tracking distance to destination in Netlogo Units
15
125.0
1

MONITOR
257
1687
466
1732
average distance to destination (type 1)
total-distance-to-destination-type-1 / counter-cars-found-parking-space-type-1
1
1
11

MONITOR
257
1740
463
1785
average distance to destination (type 2)
total-distance-to-destination-type-2 / counter-cars-found-parking-space-type-2
1
1
11

MONITOR
256
1792
499
1837
average distance to destination (wtp 0.6)
total-distance-to-destination-wtp-0.6 / counter-cars-found-parking-space-wtp-0.6
1
1
11

MONITOR
255
1844
498
1889
average distance to destination (wtp 0.7)
total-distance-to-destination-wtp-0.7 / counter-cars-found-parking-space-wtp-0.7
1
1
11

MONITOR
256
1896
488
1941
average distance to destination (wtp 1)
total-distance-to-destination-wtp-1 / counter-cars-found-parking-space-wtp-1
1
1
11

MONITOR
256
1948
506
1993
average distance to destination (wtp 1.45)
total-distance-to-destination-wtp-1.45 / counter-cars-found-parking-space-wtp-1.45
1
1
11

MONITOR
256
2000
488
2045
average distance to destination (wtp 2)
total-distance-to-destination-wtp-2 / counter-cars-found-parking-space-wtp-2
1
1
11

MONITOR
256
2052
506
2097
average distance to destination (wtp 2.32)
total-distance-to-destination-wtp-2.32 / counter-cars-found-parking-space-wtp-2.32
1
1
11

TEXTBOX
648
1295
854
1334
tracking travelled distance until parked or leaving city
15
125.0
1

MONITOR
648
1638
809
1683
average distance travelled
total-distance-travelled / counter-cars-finished
1
1
11

MONITOR
648
1687
857
1732
average distance travelled (type 1)
total-distance-travelled-type-1 / counter-cars-finished-type-1
1
1
11

MONITOR
648
1738
857
1783
average distance travelled (type 2)
total-distance-travelled-type-2 / counter-cars-finished-type-2
1
1
11

MONITOR
648
1787
864
1832
average distance travelled (wtp 0.6)
total-distance-travelled-wtp-0.6 / counter-cars-finished-wtp-0.6
17
1
11

MONITOR
648
1837
864
1882
average distance travelled (wtp 0.7)
total-distance-travelled-wtp-0.7 / counter-cars-finished-wtp-0.7
1
1
11

MONITOR
648
1886
852
1931
average distance travelled (wtp 1)
total-distance-travelled-wtp-1 / counter-cars-finished-wtp-1
1
1
11

MONITOR
648
1934
871
1979
average distance travelled (wtp 1.45)
total-distance-travelled-wtp-1.45 / counter-cars-finished-wtp-1.45
1
1
11

MONITOR
648
1984
852
2029
average distance travelled (wtp 2)
total-distance-travelled-wtp-2 / counter-cars-finished-wtp-2
1
1
11

MONITOR
648
2032
871
2077
average distance travelled (wtp 2.32)
total-distance-travelled-wtp-2.32 / counter-cars-finished-wtp-2.32
1
1
11

TEXTBOX
1030
1293
1243
1334
tracking distance travelled while searching in Netlogo Units
15
125.0
1

MONITOR
1032
1653
1232
1698
average distance spent searching
total-distance-searched / counter-cars-who-searched
1
1
11

MONITOR
1032
1704
1280
1749
average distance spent searching (type 1)
total-distance-searched-type-1 / counter-cars-who-searched-type-1
1
1
11

MONITOR
1031
1755
1279
1800
average distance spent searching (type 2)
total-distance-searched-type-2 / counter-cars-who-searched-type-2
1
1
11

MONITOR
1032
1808
1287
1853
average distance spent searching (wtp 0.6)
total-distance-searched-wtp-0.6 / counter-cars-who-searched-wtp-0.6
1
1
11

MONITOR
1032
1860
1287
1905
average distance spent searching (wtp 0.7)
total-distance-searched-wtp-0.7 / counter-cars-who-searched-wtp-0.7
1
1
11

MONITOR
1032
1908
1275
1953
average distance spent searching (wtp 1)
total-distance-searched-wtp-1 / counter-cars-who-searched-wtp-1
1
1
11

MONITOR
1032
1958
1294
2003
average distance spent searching (wtp 1.45)
total-distance-searched-wtp-1.45 / counter-cars-who-searched-wtp-1.45
1
1
11

MONITOR
1032
2007
1275
2052
average distance spent searching (wtp 2)
total-distance-searched-wtp-2 / counter-cars-who-searched-wtp-2
1
1
11

MONITOR
1033
2057
1295
2102
average distance spent searching (wtp 2.32)
total-distance-searched-wtp-2.32 / counter-cars-who-searched-wtp-2.32
1
1
11

TEXTBOX
1424
1282
1671
1330
tracking failed attempts to find a parking space per spawned car-group
15
125.0
1

MONITOR
1426
1638
1572
1683
average failed attempts
total-failed-attempts / counter-spawned-cars
1
1
11

MONITOR
1427
1687
1621
1732
average failed attempts (type 1)
total-failed-attempts-type-1 / counter-spawned-cars-type-1
1
1
11

MONITOR
1428
1737
1622
1782
average failed attempts (type 2)
total-failed-attempts-type-2 / counter-spawned-cars-type-2
1
1
11

MONITOR
1428
1786
1629
1831
average failed attempts (wtp 0.6)
total-failed-attempts-wtp-0.6 / counter-spawned-cars-wtp-0.6
1
1
11

MONITOR
1428
1835
1629
1880
average failed attempts (wtp 0.7)
total-failed-attempts-wtp-0.7 / counter-spawned-cars-wtp-0.7
1
1
11

MONITOR
1428
1883
1617
1928
average failed attempts (wtp 1)
total-failed-attempts-wtp-1 / counter-spawned-cars-wtp-1
1
1
11

MONITOR
1428
1932
1636
1977
average failed attempts (wtp 1.45)
total-failed-attempts-wtp-1.45 / counter-spawned-cars-wtp-1.45
1
1
11

MONITOR
1428
1984
1617
2029
average failed attempts (wtp 2)
total-failed-attempts-wtp-2 / counter-spawned-cars-wtp-2
1
1
11

MONITOR
1428
2038
1639
2083
average failed attempts (wtp  2.32)
total-failed-attempts-wtp-2.32 / counter-spawned-cars-wtp-2.32
1
1
11

MONITOR
702
636
759
681
gesamt
total-search-time / counter-cars-finished
1
1
11

MONITOR
702
686
759
731
Typ 1
total-search-time-type-1 / counter-cars-finished-type-1
1
1
11

MONITOR
702
733
759
778
Typ 2
total-search-time-type-2 / counter-cars-finished-type-2
1
1
11

MONITOR
705
785
779
830
Schicht 0,6
total-search-time-wtp-0.6 / counter-cars-finished-wtp-0.6
1
1
11

MONITOR
705
840
779
885
Schicht 0,7
total-search-time-wtp-0.7 / counter-cars-finished-wtp-0.7
1
1
11

MONITOR
802
643
865
688
Schicht 1
total-search-time-wtp-1 / counter-cars-finished-wtp-1
1
1
11

MONITOR
804
695
885
740
Schicht 1,45
total-search-time-wtp-1.45 / counter-cars-finished-wtp-1.45
1
1
11

MONITOR
806
747
869
792
Schicht 2
total-search-time-wtp-2 / counter-cars-finished-wtp-2
1
1
11

MONITOR
810
796
891
841
Schicht 2,32
total-search-time-wtp-2.32 / counter-cars-finished-wtp-2.32
1
1
11

PLOT
256
1337
631
1626
Distanz Parkplatz - Ziel (Durchschnitt)
Zeit (in s)
Distanz (in Netlogo-Einheiten)
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"gesamt" 1.0 0 -16777216 true "" "ifelse counter-cars-found-parking-space > 0\n[plot total-distance-to-destination / counter-cars-found-parking-space]\n[plot 0]"
"Typ 1" 1.0 0 -2674135 true "" "ifelse counter-cars-found-parking-space-type-1 > 0\n[plot total-distance-to-destination-type-1 / counter-cars-found-parking-space-type-1]\n[plot 0]"
"Typ 2" 1.0 0 -13345367 true "" "ifelse counter-cars-found-parking-space-type-2 > 0\n[plot total-distance-to-destination-type-2 / counter-cars-found-parking-space-type-2]\n[plot 0]"
"Schicht 0,6" 1.0 0 -955883 true "" "ifelse counter-cars-found-parking-space-wtp-0.6 > 0\n[plot total-distance-to-destination-wtp-0.6 / counter-cars-found-parking-space-wtp-0.6]\n[plot 0]"
"Schicht 0,7" 1.0 0 -6459832 true "" "ifelse counter-cars-found-parking-space-wtp-0.7 > 0\n[plot total-distance-to-destination-wtp-0.7 / counter-cars-found-parking-space-wtp-0.7]\n[plot 0]"
"Schicht 1" 1.0 0 -8630108 true "" "ifelse counter-cars-found-parking-space-wtp-1 > 0\n[plot total-distance-to-destination-wtp-1 / counter-cars-found-parking-space-wtp-1]\n[plot 0]"
"Schicht 1,45" 1.0 0 -2064490 true "" "ifelse counter-cars-found-parking-space-wtp-1.45 > 0\n[plot total-distance-to-destination-wtp-1.45 / counter-cars-found-parking-space-wtp-1.45]\n[plot 0]"
"Schicht 2" 1.0 0 -13840069 true "" "ifelse counter-cars-found-parking-space-wtp-2 > 0\n[plot total-distance-to-destination-wtp-2 / counter-cars-found-parking-space-wtp-2]\n[plot 0]"
"Schicht 2,32" 1.0 0 -7500403 true "" "ifelse counter-cars-found-parking-space-wtp-2.32 > 0\n[plot total-distance-to-destination-wtp-2.32 / counter-cars-found-parking-space-wtp-2.32]\n[plot 0]"

PLOT
647
1337
1014
1632
durchschnittliche zurückgelegte Strecke
Zeit (in s)
Strecke (in Netlogo Einheiten)
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"gesamt" 1.0 0 -16777216 true "" "ifelse counter-cars-finished > 0\n[plot total-distance-travelled / counter-cars-finished]\n[plot 0]"
"Typ 1" 1.0 0 -2674135 true "" "ifelse counter-cars-finished-type-1 > 0\n[plot total-distance-travelled-type-1 / counter-cars-finished-type-1]\n[plot 0]"
"Typ 2" 1.0 0 -13345367 true "" "ifelse counter-cars-finished-type-2 > 0\n[plot total-distance-travelled-type-2 / counter-cars-finished-type-2]\n[plot 0]"
"Schicht 0,6" 1.0 0 -955883 true "" "ifelse counter-cars-finished-wtp-0.6 > 0\n[plot total-distance-travelled-wtp-0.6 / counter-cars-finished-wtp-0.6]\n[plot 0]"
"Schicht 0,7" 1.0 0 -6459832 true "" "ifelse counter-cars-finished-wtp-0.7 > 0\n[plot total-distance-travelled-wtp-0.7 / counter-cars-finished-wtp-0.7]\n[plot 0]"
"Schicht 1" 1.0 0 -8630108 true "" "ifelse counter-cars-finished-wtp-1 > 0\n[plot total-distance-travelled-wtp-1 / counter-cars-finished-wtp-1]\n[plot 0]"
"Schicht 1,45" 1.0 0 -2064490 true "" "ifelse counter-cars-finished-wtp-1.45 > 0\n[plot total-distance-travelled-wtp-1.45 / counter-cars-finished-wtp-1.45]\n[plot 0]"
"Schicht 2" 1.0 0 -13840069 true "" "ifelse counter-cars-finished-wtp-2 > 0\n[plot total-distance-travelled-wtp-2 / counter-cars-finished-wtp-2]\n[plot 0]"
"Schicht 2,32" 1.0 0 -7500403 true "" "ifelse counter-cars-finished-wtp-2.32 > 0\n[plot total-distance-travelled-wtp-2.32 / counter-cars-finished-wtp-2.32]\n[plot 0]"

PLOT
1028
1336
1402
1632
durchschnittliche Suchstrecke
Zeit (in s)
Strecke (in Netlogo Einheiten)
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"gesamt" 1.0 0 -16777216 true "" "ifelse counter-cars-who-searched > 0\n[plot total-distance-searched / counter-cars-who-searched]\n[plot 0]"
"Typ 1" 1.0 0 -2674135 true "" "ifelse counter-cars-who-searched-type-1 > 0\n[plot total-distance-searched-type-1 / counter-cars-who-searched-type-1]\n[plot 0]"
"Typ 2" 1.0 0 -13345367 true "" "ifelse counter-cars-who-searched-type-2 > 0\n[plot total-distance-searched-type-2 / counter-cars-who-searched-type-2]\n[plot 0]"
"Schicht 0,6" 1.0 0 -955883 true "" "ifelse counter-cars-who-searched-wtp-0.6 > 0\n[plot total-distance-searched-wtp-0.6 / counter-cars-who-searched-wtp-0.6]\n[plot 0]"
"Schicht 0,7" 1.0 0 -6459832 true "" "ifelse counter-cars-who-searched-wtp-0.7 > 0\n[plot total-distance-searched-wtp-0.7 / counter-cars-who-searched-wtp-0.7]\n[plot 0]"
"Schicht 1" 1.0 0 -8630108 true "" "ifelse counter-cars-who-searched-wtp-1 > 0\n[plot total-distance-searched-wtp-1 / counter-cars-who-searched-wtp-1]\n[plot 0]"
"Schicht 1,45" 1.0 0 -2064490 true "" "ifelse counter-cars-who-searched-wtp-1.45 > 0\n[plot total-distance-searched-wtp-1.45 / counter-cars-who-searched-wtp-1.45]\n[plot 0]"
"Schicht 2" 1.0 0 -13840069 true "" "ifelse counter-cars-who-searched-wtp-2 > 0\n[plot total-distance-searched-wtp-2 / counter-cars-who-searched-wtp-2]\n[plot 0]"
"Schicht 2,32" 1.0 0 -7500403 true "" "ifelse counter-cars-who-searched-wtp-2.32 > 0\n[plot total-distance-searched-wtp-2.32 / counter-cars-who-searched-wtp-2.32]\n[plot 0]"

PLOT
1424
1336
1803
1633
fehlgeschlagene Parkversuche (Durchschnitt)
Zeit (in s)
Versuche
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"gesamt" 1.0 0 -16777216 true "" "ifelse counter-spawned-cars > 0\n[plot total-failed-attempts / counter-spawned-cars]\n[plot 0]"
"Typ 1" 1.0 0 -2674135 true "" "ifelse counter-spawned-cars-type-1 > 0\n[plot total-failed-attempts-type-1 / counter-spawned-cars-type-1]\n[plot 0]"
"Typ 2" 1.0 0 -13345367 true "" "ifelse counter-spawned-cars-type-2 > 0\n[plot total-failed-attempts-type-2 / counter-spawned-cars-type-2]\n[plot 0]"
"Schicht 0,6" 1.0 0 -955883 true "" "ifelse counter-spawned-cars-wtp-0.6 > 0\n[plot total-failed-attempts-wtp-0.6 / counter-spawned-cars-wtp-0.6]\n[plot 0]"
"Schicht 0,7" 1.0 0 -6459832 true "" "ifelse counter-spawned-cars-wtp-0.7 > 0\n[plot total-failed-attempts-wtp-0.7 / counter-spawned-cars-wtp-0.7]\n[plot 0]"
"Schicht 1" 1.0 0 -8630108 true "" "ifelse counter-spawned-cars-wtp-1 > 0\n[plot total-failed-attempts-wtp-1 / counter-spawned-cars-wtp-1]\n[plot 0]"
"Schicht 1,45" 1.0 0 -2064490 true "" "ifelse counter-spawned-cars-wtp-1.45 > 0\n[plot total-failed-attempts-wtp-1.45 / counter-spawned-cars-wtp-1.45]\n[plot 0]"
"Schicht 2" 1.0 0 -13840069 true "" "ifelse counter-spawned-cars-wtp-2 > 0\n[plot total-failed-attempts-wtp-2 / counter-spawned-cars-wtp-2]\n[plot 0]"
"Schicht 2,32" 1.0 0 -7500403 true "" "ifelse counter-spawned-cars-wtp-2.32 > 0\n[plot total-failed-attempts-wtp-2.32 / counter-spawned-cars-wtp-2.32]\n[plot 0]"

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
NetLogo 6.2.2
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
