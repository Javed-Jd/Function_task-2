CREATE TABLE gym_members (
    member_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    age INT NOT NULL,
    gender CHAR(1),
    weight_loss_goal DECIMAL(5, 2) NOT NULL,
    weight_gain_goal DECIMAL(5, 2) NOT NULL,
    join_date DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Table Constraints (Recommended for clarity and naming)
    CONSTRAINT age_positive CHECK (age > 0),
    CONSTRAINT gender_valid CHECK (gender IN ('M', 'F')),
    CONSTRAINT wlg_non_negative CHECK (weight_loss_goal >= 0),
    CONSTRAINT wgg_non_negative CHECK (weight_gain_goal >= 0)
);

CREATE TABLE gym_progress (
    progress_id SERIAL PRIMARY KEY,
    member_id INT NOT NULL,
    week_number INT NOT NULL,
    weight_loss DECIMAL(5, 2) NOT NULL,
    weight_gain DECIMAL(5, 2) NOT NULL,
    progress_date DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Foreign Key Constraint
    CONSTRAINT fk_member
        FOREIGN KEY (member_id)
        REFERENCES gym_members(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Check Constraints
    CONSTRAINT week_number_range CHECK (week_number >= 1 AND week_number <= 52),
    CONSTRAINT wloss_non_negative CHECK (weight_loss >= 0),
    CONSTRAINT wgain_non_negative CHECK (weight_gain >= 0),

    -- Unique Constraint (Prevents duplicate entries for the same member in the same week)
    CONSTRAINT uq_member_week UNIQUE (member_id, week_number)
);

select * from gym_members;
select * from gym_progress;

CREATE OR REPLACE FUNCTION insert_gym_member_with_aggregate()
RETURNS void AS $$
DECLARE
    new_member_id INT;
    max_id INT;
BEGIN
    SELECT coalesce(max(member_id), 0) INTO max_id FROM gym_members;
    
    new_member_id := max_id + 1;
    
    INSERT INTO gym_members (
        member_id, 
        first_name, 
        last_name, 
        age, 
        gender, 
        weight_loss_goal, 
        weight_gain_goal, 
        join_date
    )
    VALUES (
        new_member_id, 'Generated', 'Member', 25,'F', 1.00,2.00, current_date);
END;
$$ LANGUAGE plpgsql;

select insert_gym_member_with_aggregate();


create or replace function insert_gym_progress_with_aggregate()
returns void as $$
declare
    member_id int;
    max_progress_id int;
    new_progress_id int;
begin
    select coalesce(max(id), 0) into max_progress_id from gym_progress;

    new_progress_id := max_progress_id + 1;
    select max(id) into member_id from gym_members;
    insert into gym_progress (id, member_id, progress_date, progress_metric)
    values (new_progress_id, member_id, current_date, 0);
end;
$$ language plpgsql;



CREATE OR REPLACE FUNCTION insert_gym_progress_with_aggregate()
RETURNS void AS $$
DECLARE
    member_id INT;
    max_progress_id INT;
    new_progress_id INT;
BEGIN
    SELECT coalesce(max(progress_id), 0) INTO max_progress_id FROM gym_progress;

    new_progress_id := max_progress_id + 1;
        SELECT max(gym_members.member_id) INTO member_id FROM gym_members;
    INSERT INTO gym_progress (
        progress_id, 
        member_id, 
        week_number, 
        weight_loss, 
        weight_gain, 
        progress_date
    )
    VALUES (
        new_progress_id, member_id, 1,0.00,0.00,current_date);
END;
$$ LANGUAGE plpgsql;


select insert_gym_progress_with_aggregate();
