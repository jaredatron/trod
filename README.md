# T.R.O.D

Test Run On Demand


# How it works

When you run `trod`:

  0. a single machine (the arbiter) is started in the cloud for your project/sha
  0. a static html5 app pointed at your test run is generated, uploaded to s3, and opened in your browser

The html5 web app for your test run auto refreshes to display the following events:

  0. the arbiter detects the tests needing to be run for your project at that sha
  0. the arbiter then spawns worker instances in the cloud to run those tests
  0. the workers run through the tests queues one at a time and then shut down
  0. the arbiter does any post processing you may need and then shuts down

---

# The cloud instances

  Both the arbiter and the worker instances come from the same image. Sn init script reads a json config in an instance tag to decide what roll the instance plays.

## The instance init script

  When any instance starts an init script does the following:

  0. reads it's json config from the instance tags
  0. does a shallow checkout of the project at the given sha
  0. partially sets up the project workspace (bundle install etc.)
    * ? should we have a .trod config file containing a setup command to support rvm & bundler or should .trod know about rvm bundler ?
  0. becomes an arbitor or worker depending on the config (see sections "The Arbiter" & "A Worker")
    * this runs the same trod gem executable you run on the client

## The arbiter

  The arbiter instance is started with a config like the following:

      {
        project: "git://github.com/you/project.git",
        sha: "44485e3f9acb760b3eccf218d056f891c959cb51",
        arbiter: true,
        workers: {
          rspec: 10,
          cucumber: 25,
        }
      }

  The init script will start trod using the following command:

      trod arbiter

  The arbiter process then does the following:

  0. read the current sha and use it as the test run uuid
  0. starts a redis server
  0. writes a test_run.json file to S3 to report its state (1)
  0. detects the tests needing to be run
  0. stores tests in redis lists, one for each type (rspec, cucumber, etc.)
  0. starts the workers (example: 10 rspec servers and 15 cucumber servers)
  0. loops reporting it's state to S3 until all queues are empty & all workers are unregistered
  0. runs a post-processing hook (for things like simplecov)
  0. writes it's last report
  0. shuts down

  (1) this json file is constantly written to S3 and used by the web app to display the state of the test run

## A worker

  A worker is an cloud instance running your project in "test server mode". The worker then pulls from a queue
  of tests and runs each test one by one.

  A worker is started with a config like the following:

      {
        project: "git://github.com/you/project.git",
        sha: "44485e3f9acb760b3eccf218d056f891c959cb51",
        arbiter: "redis://ec2-0-0-0-0.compute-1.amazonaws.com:6380/0",
        worker: "rspec"
      }

  The init script will start trod using the following command:

      trod worker --type=rspec --redis="redis://ec2-0-0-0-0.compute-1.amazonaws.com:6380/0"

  The worker process then does the following:

  0. read the current sha and use it as the test run uuid
  0. registers it's self as a worker in redis
  0. reports its preparing the workspace
  0. runs the workspace prepare hook (db schema setup etc.)
  0. reports its starting the test server
  0. starts cucumber or rspec in server mode (TBD: same process or other process?)
  0. loop until test queue is empty:
    0. pop a job (sounds like a pizza place)
    0. registers it's working on that job
    0. reports test complete with result
    0. if the test didnt pass and it hasent exceeded it's attempts allawence, stick it back on the front of the queue
    0. runs after test hook (upload artifacts, reset logfiles etc.)
  0. unregister its self
  0. shutdown


# The test_run.json file

WIP:

            {
              status: "",
              tests: [
                {
                  status: "",
                  type: "spec",
                  name: "spec/models/user_spec.rb",
                  tries: 1,
                  result: pass
                }
              ],
              workers: [
                {
                  status: ""
                  host: 'ec2-0-0-0-0.compute-1.amazonaws.com',
                }
              ]
            }


---

# Things to note

  * the git sha is used as the test run uuid
  * all of trod lives in a gem you can include into your project
  * the only code that doesnt live in the trod gem is the init scipts on the servers
  * the html5 app should use the freshness of the json file it loads as a heartbeat for the arbiter

# Questions

  * should we pass all the fog (s3/ec2) cridentials through the config json in the instance tag?
    * this means projects dont have those creds in the repo
  * should we make a server / client distinction from the start?
    * we could write this so any project of any language could use it as long as it writes a compatible client (v2?)
  * should we use a UUID other then the git sha to make it easier to re-run a sha?

# TODO

  * add a way of persisting runtime across test runs so we can sort tests longest first
  * enable the arbiter to use est runtimes to calculate how many workers are needed based on a target total runtime


## Installation

Add this line to your application's Gemfile:

    gem 'trod'

And then execute:

    $ bundle


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
