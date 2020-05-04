# scheduling-repl
A WIP scheduling based project.

Nothing about this is close to REPL, but an attempt will be made to manufacture a coherent command list to assist in daily scheduling as well as (and more importantly) assist in scheduling items over an arbitrarily large time duration.

## Two Systems

### Daily Scheduler

Module which crafts and handles my daily routine based on my inputs. It talks to the long term scheduler to make sure whatever I do in a day is aligned with my long term goals.

#### Existing Features

* Takes inputs in the form of task names, duration ranges, time ranges, number of times you have to do this particular task and so on.
* Tries to fit as many items in order of priority as possible.
* Presents a routine in text form.

#### Future Goals

* Connect this module with LTS.

### Long Term Scheduler

Module which crafts and handles my long term goals based on my inputs. It talks to the daily scheduler to see how well I do assigned tasks. On that basis it adjusts its pace of dissemination of tasks and informs me of the viability of timelines set by me.

#### Existing Features

Tumbleweed.

#### Future Goals

* Its existence.