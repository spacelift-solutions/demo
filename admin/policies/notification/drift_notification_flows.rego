package spacelift

# Send updates about tracked runs to discord.
webhook[wbdata] {
  endpoint := input.webhook_endpoints[_]
  endpoint.id == "kals-flows-notifications"
  stack := input.run_updated.stack
  run := input.run_updated.run
  wbdata := {
    "endpoint_id": endpoint.id,
    "payload": {
      "embeds": [{
        "title": "Drift detected!",
        "description": sprintf("Stack: [%s](http://spacelift-solutions.app.spacelift.io/stack/%s)\nRun ID: [%s](http://spacelift-solutions.app.spacelift.io/stack/%s/run/%s)\nRun state: %s", [stack.name,stack.id,run.id,stack.id, run.id,run.state]),
        }]
     }
  }
  
  # Send notification via above webhook ^
  # ONLY if drift is detected with more than 1 change
  input.run_updated.run.drift_detection
  count(input.run_updated.run.changes) > 0
}

sample := true
