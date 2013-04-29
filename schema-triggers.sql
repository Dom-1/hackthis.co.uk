-- This SQL creates the triggers to maintain data integrity.
USE hackthis; -- Make sure we are in the correct database.

delimiter |
DROP TRIGGER IF EXISTS delete_user;
CREATE TRIGGER delete_user BEFORE DELETE ON users FOR EACH ROW
	BEGIN
		DELETE FROM users_profile WHERE OLD.user_id = user_id;
		DELETE FROM users_priv WHERE OLD.user_id = user_id;
		DELETE FROM users_friends WHERE OLD.user_id = user_id OR OLD.user_id = friend_id;
		DELETE FROM users_blocks WHERE OLD.user_id = user_id OR OLD.user_id = blocked_id;
		DELETE FROM users_activity WHERE OLD.user_id = user_id;
		DELETE FROM users_notifications WHERE OLD.user_id = user_id;
		DELETE FROM users_medals WHERE OLD.user_id = user_id;
		-- Add other tables to be removed.
	END;


DROP PROCEDURE IF EXISTS award_medal;
CREATE PROCEDURE `award_medal` (IN _user_id INT, IN _medal_id INT)
DETERMINISTIC
COMMENT 'Give user relevant score based on medal being awarded'  
BEGIN
	DECLARE REWARD INT;
	SET REWARD = (SELECT medals_colours.reward FROM `medals` INNER JOIN `medals_colours` on medals.colour_id = medals_colours.colour_id WHERE medals.medal_id = _medal_id LIMIT 1);

	UPDATE users SET score = score + REWARD WHERE user_id = _user_id LIMIT 1;
END;

DROP TRIGGER IF EXISTS insert_medal;
CREATE TRIGGER insert_medal AFTER INSERT ON users_medals FOR EACH ROW
	BEGIN
		CALL award_medal(NEW.user_id, NEW.medal_id);
	END;
|

-- ARTICLES
-- TODO: Pull the user id and a comment made to the new version.

DROP TRIGGER IF EXISTS articales_draft_update_audit;
CREATE TRIGGER articales_draft_update_audit BEFORE UPDATE ON articles_draft FOR EACH ROW
	BEGIN
		IF OLD.body <> NEW.body THEN
			INSERT INTO articles_audit (article_id, draft, field, old_value, new_value) 
				VALUES(NEW.article_id, 1, 'body', OLD.body, NEW.body);
		END IF;

		IF OLD.category_id <> NEW.category_id THEN
			-- Get the string title of the category from the cat id.
			SET @old_cat = (SELECT title FROM articles_categories WHERE category_id = OLD.category_id);
			SET @new_cat = (SELECT title FROM articles_categories WHERE category_id = NEW.category_id);

			INSERT INTO articles_audit (article_id, draft, field, old_value, new_value) 
				VALUES(NEW.article_id, 1, 'category_id', @old_cat, @new_cat);
		END IF;

		IF OLD.title <> NEW.title THEN
			INSERT INTO articles_audit (article_id, draft, field, old_value, new_value) 
				VALUES(NEW.article_id, 1, 'title', OLD.title, NEW.title);
		END IF;
	END;

DROP TRIGGER IF EXISTS articales_update_audit;
CREATE TRIGGER articales_update_audit BEFORE UPDATE ON articles FOR EACH ROW
	BEGIN
		IF OLD.title <> NEW.title THEN
			INSERT INTO articles_audit (article_id, draft, field, old_value, new_value) 
				VALUES(NEW.article_id, 0, 'title', OLD.title, NEW.title);
		END IF;

		IF OLD.slug <> NEW.slug THEN
			INSERT INTO articles_audit (article_id, draft, field, old_value, new_value) 
				VALUES(NEW.article_id, 0, 'slug', OLD.slug, NEW.slug);
		END IF;

		IF OLD.category_id <> NEW.category_id THEN	
			-- Get the string title of the category from the cat id.
			SET @old_cat = (SELECT title FROM articles_categories WHERE category_id = OLD.category_id);
			SET @new_cat = (SELECT title FROM articles_categories WHERE category_id = NEW.category_id);

			INSERT INTO articles_audit (article_id, draft, field, old_value, new_value) 
				VALUES(NEW.article_id, 0, 'category_id', @old_cat, @new_cat);
		END IF;

		IF OLD.body <> NEW.body THEN
			INSERT INTO articles_audit (article_id, draft, field, old_value, new_value) 
				VALUES(NEW.article_id, 0, 'body', OLD.body, NEW.body);
		END IF;

		IF OLD.thumbnail <> NEW.thumbnail THEN
			INSERT INTO articles_audit (article_id, draft, field, old_value, new_value) 
				VALUES(NEW.article_id, 0, 'thumbnail', OLD.thumbnail, NEW.thumbnail);
		END IF;

		IF OLD.featured <> NEW.featured THEN
			INSERT INTO articles_audit (article_id, draft, field, old_value, new_value) 
				VALUES(NEW.article_id, 0, 'featured', OLD.featured, NEW.featured);
		END IF;

	END;
|
delimiter ;