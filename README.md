# BeamRED

## History
This library is made out of pure frustration regarding industrial automation and private home automation.
The most important thing of automation control is reliability. PLC are the defacto standart in the industry
to solve a wide range of problems. Though they are quite good in what they are, they have some downside when
the problems get more and more complex.
With complex I mean distributed.
Here is where Erlang/Beam shines and luckily there is made great investment in developing an embedded Elixir
called Nerves.
The only problem I had with Nerves, was the long feedback loop when developing things. Though it is as stable
as it can get, sometimes I wish I could just plug some nodes in NodeRED and deploy them.
And that is what this library tries to solve.
It uses NodeRED Editor-Client as the frontend and implements a NodeRED runtime in elixir.
The backend is communicating with the frontend with the help of phoenix.

![Screenshot](./.github/imgs/beamred_diagram.svg)
