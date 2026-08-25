---
last_reviewed: 2026-05-19
---

# Common troubleshooting scenarios

Specific guidance for frequently encountered situations. Read the scenario that
matches what you're seeing — don't read all of them.

## Scenario 1: Repeated test failures

Tests keep failing after multiple attempts to fix them.

**Do NOT:** keep making random changes hoping something works; say "I'm not sure
why this isn't working" without analysis; blame the test or codebase.

**DO:**

1. **Stop and analyze.**
   > I've tried fixing this test 3 times and I'm not making progress. Let me
   > take a step back.
   >
   > The test expects: [expected behavior]
   > The test is failing with: [actual error]
   >
   > I think the issue is: [hypothesis]

2. **Propose a debugging approach.**
   > Let's debug this systematically:
   > 1. Verify the test setup is correct
   > 2. Check if my understanding of expected behavior matches yours
   > 3. Trace through the code path to find the disconnect

3. **Ask for help if needed.**
   > I'm having trouble identifying why this is failing. Could you:
   > - Run the test locally and share the full error output?
   > - Verify that my understanding of expected behavior is correct?
   > - Point me to a similar working test as reference?

## Scenario 2: Unclear requirements

The task description could be interpreted multiple ways.

**Do NOT:** make assumptions and hope you guessed right; build the wrong thing
and waste time; ask "what do you mean?" without being specific.

**DO:**

1. **State your interpretation.**
   > Let me make sure I understand correctly. When you say "bulk upload
   > enrollments," I'm interpreting this as:
   > - Admin uploads a CSV file
   > - System validates the data
   > - If valid, creates enrollments for all rows
   > - If any row is invalid, roll back the entire batch
   >
   > Is this correct?

2. **Present edge cases.**
   > A few edge cases to clarify:
   > - What if an enrollment already exists for a subscriber/plan combo?
   > - Should we update existing enrollments or skip them?
   > - What if the CSV has 10,000 rows — should this be processed async?

3. **Start with the clear parts.**
   > While you clarify those edge cases, I'll start with the parts I'm
   > confident about: CSV parsing, basic validation, model structure. We can
   > iterate once clarified.

## Scenario 3: Can't find relevant code

You've searched but can't find where existing functionality lives.

**Do NOT:** give up and say "I can't find it"; recreate functionality that
already exists; search aimlessly.

**DO:**

1. **Show what you've searched.**
   > I'm trying to find the enrollment eligibility logic. I've checked:
   > - app/models/enrollment.rb — validations but not eligibility rules
   > - app/services/ — searched "eligibility", found nothing
   > - lib/enrollment/ — enrollment processing but not eligibility
   >
   > Could you point me to where this logic lives? Or should I create it from
   > scratch?

2. **Ask for navigation help.**
   > I'm not familiar with this codebase yet. For features related to X, where
   > would I typically find: the model logic? business rules? external
   > integrations?

3. **Propose creating it.**
   > I couldn't find existing X logic. I can create it in [location]. Does
   > that sound right, or is there existing code I should build on?

## Scenario 4: Made a wrong assumption

You built something based on a wrong assumption.

**Do NOT:** pretend you didn't make a mistake; defend the wrong approach; get
defensive or make excuses.

**DO:**

1. **Acknowledge quickly.**
   > I realize I misunderstood the requirement. I assumed X, but I see now
   > that it's actually Y. The code I wrote is based on the wrong assumption,
   > so I need to refactor it.

2. **Assess the damage.**
   > The good news: tests and database structure are still correct. What
   > needs to change: the service object logic.

3. **Move forward.**
   > I'm going to:
   > 1. Refactor the service object to handle [correct approach]
   > 2. Update the tests to match the new behavior
   > 3. Verify everything still works

## Scenario 5: Task is too complex

The task is very large and you're overwhelmed.

**Do NOT:** try to do everything at once; ask the user to break it down for
you; give up or say it's too complex.

**DO:**

1. **Break it down yourself.**
   > This is a substantial feature. Let me break it down:
   >
   > Phase 1: Data Model — migration, model with validations, model tests
   > Phase 2: Business Logic — service object, error handling, service tests
   > Phase 3: API/Controllers — controller actions, request validation, tests
   >
   > Does this breakdown make sense? Should we start with Phase 1?

2. **Propose an MVP.**
   > Can we start with an MVP that:
   > - Handles the happy path
   > - Has basic validation
   > - Skips advanced error handling for now
   > - Skips notifications for now
   >
   > Then we can iterate and add the remaining pieces?

## Scenario 6: Environment or setup issue

Can't run/test code due to environment problems.

**Do NOT:** keep trying the same thing; assume it's not your problem; give
vague "it doesn't work" messages.

**DO:**

1. **Provide detailed error info.**
   > I'm getting an error when trying to run the tests:
   >
   > Error: [exact error message]
   >
   > Environment: Rails X.X, Ruby X.X, MySQL/Postgres X
   >
   > I've checked: [list what you verified, with PASS/FAIL]
   >
   > Could you confirm [specific question]?

2. **Suggest workarounds.**
   > While we troubleshoot the test environment, I can:
   > - Continue writing the code (even if we can't test it yet)
   > - Review the logic manually
   > - Write the tests so they're ready to run once the environment is fixed
   >
   > Would you prefer I do that, or should we fix the environment first?
