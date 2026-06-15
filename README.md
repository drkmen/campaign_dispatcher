### Setup
Make sure you have Ruby 3.4.6, PostgreSQL and Redis installed and running.

Run the following commands to setup the application:
```bash
bundle install

# create a database.yml file and update your database credentials
cp config/database.yml.example config/database.yml

rails db:create db:migrate

# since sharing master.key is a bad idea even here, rewrite the secrets:
rm config/credentials.yml.enc config/master.key
rails credentials:edit
```
Then run each:
1. `rails s`
2. `rails tailwindcss:watch`
3. `sidekiq`

Visit http://localhost:3000 to view the application.

### Architectural Decisions

Instead of reaching for complex Stimulus controllers or custom ActionCable channels for every update, this project utilizes **native Rails `after_update_commit` hooks**. 
- **Simplicity:** By leveraging `broadcasts_to`, we keep the frontend logic minimal and the backend as the single source of truth.
- **Reliability:** Using `after_commit` ensures that broadcasts only occur after the database transaction is finalized, preventing race conditions where the UI updates before the data is available to background workers.
- **Resilience:** A failure in sending to one recipient (e.g., due to an invalid email or transient API error) does not crash the entire campaign dispatch.
- **Idempotency:** The dispatch logic is designed to be idempotent, allowing safe retries without risking duplicate sends or inconsistent states.
- **Nested Attributes:** Used `accepts_nested_attributes_for` to handle campaign and recipient creation in a single atomic operation, simplifying the controller and form logic.

### Future Improvements (40-hour Scope)

While the current implementation is robust for moderate loads, the following enhancements are planned for high-scale production use:

- **Dockerized Environment:** Containerize the application with Docker Compose for easier local development and deployment.
- **Errors Handling:** Improve error handling to gracefully handle unexpected exceptions and recover from transient issues.
- **Specs coverage:** Add comprehensive test coverage with more negative scenarios.
- **Batch Inserts:** Split single job dispatch into multiple batches to improve performance for large campaigns.
- **Redis-backed Progress:** Transition real-time progress indicators (e.g., "5 of 10 sent") to Redis counters to avoid excessive database `COUNT` queries during high-concurrency dispatch.
- **Service Object Pattern:** Refactor dispatch logic into specialized service objects as business rules grow in complexity.
- **UI/views cleanup:** Refactor views introducing partials and reusing components for consistency. 

### Testing

Run tests with:
```bash
bundle exec rspec
```
