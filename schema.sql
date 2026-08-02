USE prolific_analytics;

DROP TABLE IF EXISTS engagement_events;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS submissions;
DROP TABLE IF EXISTS studies;
DROP TABLE IF EXISTS onboarding;
DROP TABLE IF EXISTS participants;

CREATE TABLE participants (
    participant_id      VARCHAR(20) PRIMARY KEY,
    signup_date          DATETIME,
    acquisition_channel   VARCHAR(50),
    country               VARCHAR(50),
    age                   INT,
    gender                VARCHAR(30),
    device_type           VARCHAR(20),
    last_activity_date    DATETIME NULL,
    account_status        VARCHAR(20)
);

CREATE TABLE onboarding (
    participant_id                    VARCHAR(20) PRIMARY KEY,
    signup_date                       DATETIME,
    email_verified_date               DATETIME NULL,
    profile_completed_date            DATETIME NULL,
    demographic_survey_completed_date DATETIME NULL,
    first_study_completed_date        DATETIME NULL,
    is_activated                      TINYINT(1)
);

CREATE TABLE studies (
    study_id               VARCHAR(20) PRIMARY KEY,
    study_name              VARCHAR(255),
    category                 VARCHAR(50),
    researcher_type          VARCHAR(30),
    posted_date               DATETIME,
    avg_completion_minutes    DOUBLE,
    reward_amount              DOUBLE,
    places_available           INT
);

CREATE TABLE submissions (
    submission_id            VARCHAR(20) PRIMARY KEY,
    participant_id            VARCHAR(20),
    study_id                   VARCHAR(20),
    submission_date             DATETIME,
    completion_time_minutes     DOUBLE,
    status                       VARCHAR(20),
    reward_earned                 DOUBLE,
    INDEX idx_participant (participant_id),
    INDEX idx_study (study_id)
);

CREATE TABLE payments (
    payment_id       VARCHAR(20) PRIMARY KEY,
    participant_id     VARCHAR(20),
    submission_id        VARCHAR(20) NULL,
    amount                 DOUBLE,
    payment_date             DATETIME,
    payment_type               VARCHAR(30),
    INDEX idx_participant (participant_id)
);

CREATE TABLE engagement_events (
    event_id           VARCHAR(20) PRIMARY KEY,
    participant_id       VARCHAR(20),
    event_type             VARCHAR(30),
    event_timestamp          DATETIME,
    INDEX idx_participant (participant_id),
    INDEX idx_timestamp (event_timestamp)
);
