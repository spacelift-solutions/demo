package spacelift

# Automatically approve any runs that don't originate from a fork
approve { count(input.run.flags) == 0 }
approve { input.run.flags[_] != "is_fork" }

# Otherwise, require at least one approval to start the run
approve { count(input.reviews.current.approvals) >= 1 }
reject  { count(input.reviews.current.rejections) >= 1 }

sample := true
