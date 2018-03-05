# What should I do if a record is invalid?

Rails validations are there to prevent an object to get into an invalid state. For example, if a field named `ssn` is mandatory for an `Employee` record, it means you won't be able to save an employee without a ssn, and you won't be able to delete the ssn of an existing employee. Unfortunately, some records in the database can get into an invalid state (the goal of this gem is to detect them.) To be able to fix them, you need to understand how they got into this state first. There are very common causes to this issue.

# How does a record (from the database) gets into an invalid state? (and how to avoid this problem)

- Problem: Rails provides some methods and techniques to skip validations (for example `update_column` and `update_attribute` - [see the list here](http://guides.rubyonrails.org/active_record_validations.html#skipping-validations)).
- Solution: be extra careful with these methods, or just stop using them.

- Problem: Validation checks the presence of an associated record which has been deleted (for example 'company_id' is set but the returned company is `nil`).
- Solution: there is probably a `dependent: :destroy` missing. If the `dependent` is present, you should also be extra careful with `delete` (because this won't run this callback). Use `destroy` instead.

- Problem: The validation was added in the code after this record was saved and they got overlooked.
- Solution: When you add a validation, be careful to not break existing records.

- Problem: Validation is (too) complex: it tries to enforce a business rule involving other records. Changing the state of on of the involved record is valid by itself, but is breaking this validation. Example: let's say a company with fast payroll is invalid if 3 employees or more don't have their birthday set - employees may unset their birthday for a legit reason and the company could break mysteriously.
- Solution: This should not be a validation but this logic should be in the business layer.

- Problem: Validation is time sensitive: maybe this validation will fail every Sunday.
- Solution: Something is probably wrong with the validation. Try to move it to the business layer.

- Problem: Validation checks uniqueness (`uniqueness: true`) but I get duplicated records.
- Solution: A race condition can happen with rails validations. You may need a unique index. See [this article](https://robots.thoughtbot.com/the-perils-of-uniqueness-validations)

- Problem: Validation is called too often (a `if` condition is missing)
- Solution: Check [Conditional validation](http://guides.rubyonrails.org/active_record_validations.html#conditional-validation) and try to understand if you should run the validation all the time, or only in some specific occasions.

# Why should I care anyway?

Validations errors are a massive problem. If a record is in an invalid state, it could be a compliance issue or a customer could lose money. It also mean *nothing can update or save this record until it is fixed*, which can be the source of many extra errors and cause data corruption.
