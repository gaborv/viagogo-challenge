UX notes
========
I put significant work into creating a grouping system which is easily configurable to display live data in relevant groups to the user.

Particularly instead of pointing out the cheapest ticket in a particular country I believe it can be more useful the see the events grouped by distance from the user and the cheapest event is highlighted in each category.

For demonstration purposes I set up the users location to be in Zurich, Switzerland.



Technical concept
=============

The backend is responsible for routing, while the frontend widgets can display an active overview of the upcoming U2 concerts or the listings for one particular concert. 

It is backend responsibility to aquire access tokens (to avoid sending out clientid/secret) information to the public.

The frontend every once in a while polls the API for upadated data and displays that seamlesly.
Reorganization of the data should occur immediately in the browser without page reload. If the amount of data is too large it can involve a new API request.


Implementation
==============

The project is split to a backend and frontend components.
Most of the logic is in the frontend. It is responsible for
1. Querying the Viagogo API for up to date event data
1. Displaying the events in groups starting with the most relevant for the user
1. Highlighting the cheapest available events in each group. This updates if there is a change in the data.

Backend:
1. It has one controller with a single view to launch the frontend widget.
1. It has an access token provider, but in its current, limited implementation it asks for a new accessToken on each request and the client ID and secret are hard coded.

Other limitations: I did not have enought time to create a Listings page.

Building the frontend:
    
    npm install
    npm build:debug     -- this will also copy the generated JS file to wwwroot/js
    npm test


Building the backend: should be ok from Visual Studio, although I was using Visual Studio for Mac.

For convenience I icluded the generated js files in the backend codebase, so the frontend build can be skipped.

