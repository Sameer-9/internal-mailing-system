PGDMP                 	        {            mail_db    14.5    14.5 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    84383    mail_db    DATABASE     c   CREATE DATABASE mail_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'English_India.1252';
    DROP DATABASE mail_db;
                postgres    false                       1255    94243 8   add_label(integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.add_label(user_id integer, label_name character varying, color_hex character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$
DECLARE
	output_result JSONB := '{}';
	rows_count INTEGER;
	label_id INTEGER;
BEGIN

	SELECT COUNT(*) FROM user_label WHERE name = $2 AND user_lid = $1 AND active = true INTO rows_count;
	
	IF rows_count <> 0 THEN
		output_result := '{"status": 400, "message": "Label With Same Name Already Exists!"}';
		RETURN output_result;
	END IF;
	
	INSERT INTO user_label(user_lid, name, color_hex, created_by)
		VALUES($1, $2, $3, $1) RETURNING id INTO label_id;
	
	output_result := '{"status": 200, "message": "Label Addes Successfully!", "id": ' || label_id || '}';
		RETURN output_result;
END
$_$;
 l   DROP FUNCTION public.add_label(user_id integer, label_name character varying, color_hex character varying);
       public          postgres    false                        1255    93234    create_conversation(jsonb)    FUNCTION     �	  CREATE FUNCTION public.create_conversation(input_json jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

DECLARE
output_result JSONB;
conversation_lid INT;
message_lid INT;

-- '{
--   "conversation": {
--     "created_by": 1,
--     "subject": "Test Subject",
--     "body": "test body message"
--   },
--   "users_array": [
--       {
--         "user_id": 1,
--         "participation_type_id": 1
--       },
--       {
--         "user_id": 2,
--         "participation_type_id": 3
--       },
--       {
--         "user_id": 3,
--         "participation_type_id": 4
--       }
--     ]
-- }'

BEGIN

	RAISE NOTICE '%', input_json['conversation'];
	
 	  DROP TABLE IF EXISTS temp_conv;
      CREATE TEMPORARY TABLE temp_conv(
          id serial,
          created_by int NOT NULL,
          subject varchar(300),
          body TEXT
        );
		
	  DROP TABLE IF EXISTS temp_participant;
      CREATE TEMPORARY TABLE temp_participant(
          id serial,
          user_lid int NOT NULL,
          participation_type_id INT NOT NULL
        );

      INSERT INTO
        temp_conv(created_by,subject,body)
      SELECT
        CAST(input_json['conversation'] ->> 'created_by' AS int) "created_by",
        input_json['conversation'] ->> 'subject' AS "approved_by",
        input_json['conversation'] ->> 'body' AS "body";
		
	INSERT INTO
        temp_participant(user_lid,participation_type_id)
      SELECT
        CAST(t ->> 'user_id' AS int) "user_id",
        CAST(t ->> 'participation_type_id' AS int) "participation_type_id"
		FROM jsonb_array_elements(input_json['users_array']) AS t;

	INSERT INTO conversation (subject,created_by) 
	 (SELECT subject,created_by FROM temp_conv)
	 RETURNING id INTO conversation_lid;

	INSERT INTO conversation_participant(conversation_lid,user_lid,modified_by)
	(SELECT DISTINCT conversation_lid,user_lid,(SELECT created_by FROM temp_conv)
		FROM temp_participant);
	
	INSERT INTO message(conversation_lid,body,created_by) 
	 (SELECT conversation_lid,body,created_by FROM temp_conv)
	 RETURNING id INTO message_lid;
	 
	 INSERT INTO message_recepient(message_lid,user_lid,participant_type_lid,created_by,modified_by)
	 (SELECT message_lid,user_lid,participation_type_id,
	  (SELECT created_by FROM temp_conv),
	  (SELECT created_by FROM temp_conv)
	  FROM temp_participant
	 );
	 
	output_result := json_build_object('conversation_lid', conversation_lid, 'message_lid', message_lid);

RETURN
  output_result;

END
$$;
 <   DROP FUNCTION public.create_conversation(input_json jsonb);
       public          postgres    false                       1255    94229    delete_label(integer, integer)    FUNCTION     �  CREATE FUNCTION public.delete_label(user_id integer, label_id integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$
DECLARE
	output_result JSONB := '{}';
	rows_count INTEGER;
BEGIN

	RAISE NOTICE 'USER >>>>>> %', user_id ;

 	SELECT COUNT(*) FROM user_label WHERE id = $2 AND user_lid = $1 INTO rows_count;
  
  	RAISE NOTICE 'ROWS COUNT >>>>>> %', rows_count ;

	IF rows_count <> 1 THEN
		 output_result := '{"status": 400, "message": "Request IS not Valid!"}';
		 RETURN output_result;
	END IF;
	
	UPDATE user_label SET active = false WHERE id = $2;
	
	output_result := '{"status": 200, "message": "Label Removed Successfully!"}';
	RETURN output_result;
END
$_$;
 F   DROP FUNCTION public.delete_label(user_id integer, label_id integer);
       public          postgres    false                       1255    95106 1   get_inbox_conversation(integer, integer, integer)    FUNCTION     t  CREATE FUNCTION public.get_inbox_conversation(user_id integer, offset_val integer, limit_val integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$
DECLARE
	output_result JSONB := '{}';
BEGIN

	RAISE NOTICE 'USER >>>>>> %', $1 ;

  output_result['conversations'] := 
							  (
							  SELECT
								JSONB_AGG(TO_JSONB(t.*))
							  FROM
								(
								  SELECT
									c.subject, c.id, ss.sender, ss.body as message,
									TO_CHAR(ss.created_date, 'Mon DD') as date,
									ss.is_read, cp.is_starred, false as is_checked
								  FROM
									(
									  SELECT
										m.conversation_lid, m.body, m.created_date,
										CONCAT(pu.first_name, ' ', pu.last_name) AS sender,
										mr.is_read
									  FROM message m
										INNER JOIN (
										  SELECT
											conversation_lid,
											MAX(created_date) as max_date
										  FROM message
										  GROUP BY conversation_lid
										) AS ml ON ml.conversation_lid = m.conversation_lid
										INNER JOIN message_recepient mr ON mr.message_lid = m.id
										INNER JOIN public.user pu ON pu.id = m.created_by
										AND m.created_date = ml.max_date
										AND mr.participant_type_lid <> 2
										AND mr.active = TRUE AND m.active = TRUE
										AND pu.active = TRUE AND mr.user_lid = $1
									  ORDER BY
										m.created_date DESC
									) AS ss
									INNER JOIN conversation c ON c.id = ss.conversation_lid
									INNER JOIN conversation_participant cp ON cp.conversation_lid = c.id
								  WHERE
									cp.user_lid = $1
									AND c.active = true AND cp.active = true
								  ORDER BY
									ss.created_date DESC
								  LIMIT
									$3
								  OFFSET $2
								) t
							);
  
  
  output_result['pagination'] := 
  					(
						SELECT 
						TO_JSONB(
							json_build_object(
								'total_count', t.total,
								'has_previous', CASE WHEN $2 > 0 THEN true ELSE false END,
								'has_next', CASE WHEN t.total > ($2 + $3) THEN true ELSE false END
							)
						) FROM
						(
								  SELECT
									COUNT(*) as total
								  FROM
									(
									  SELECT
										m.conversation_lid, m.body, m.created_date,
										CONCAT(pu.first_name, ' ', pu.last_name) AS sender,
										mr.is_read
									  FROM message m
										INNER JOIN (
										  SELECT
											conversation_lid,
											MAX(created_date) as max_date
										  FROM message
										  GROUP BY conversation_lid
										) AS ml ON ml.conversation_lid = m.conversation_lid
										INNER JOIN message_recepient mr ON mr.message_lid = m.id
										INNER JOIN public.user pu ON pu.id = m.created_by
										AND m.created_date = ml.max_date
										AND mr.participant_type_lid <> 2
										AND mr.active = TRUE AND m.active = TRUE
										AND pu.active = TRUE AND mr.user_lid = $1
									  ORDER BY
										m.created_date DESC
									) AS ss
									INNER JOIN conversation c ON c.id = ss.conversation_lid
									INNER JOIN conversation_participant cp ON cp.conversation_lid = c.id
								  WHERE
									cp.user_lid = $1
									AND c.active = true AND cp.active = true
								) t
					);
  
  
RETURN output_result;

END
$_$;
 e   DROP FUNCTION public.get_inbox_conversation(user_id integer, offset_val integer, limit_val integer);
       public          postgres    false                       1255    95114 0   get_sent_conversation(integer, integer, integer)    FUNCTION     �  CREATE FUNCTION public.get_sent_conversation(user_id integer, offset_val integer, limit_val integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$
DECLARE
	output_result JSONB := '{}';
BEGIN

	RAISE NOTICE 'USER >>>>>> %', user_id ;

  output_result['conversations'] := 
							  (
							  SELECT
								JSONB_AGG(TO_JSONB(t.*))
							  FROM
								(
								  SELECT
									c.subject, c.id, ss.sender, ss.body as message,
									TO_CHAR(ss.created_date, 'Mon DD') as date,
									ss.is_read, cp.is_starred, false as is_checked, ss.sent_users
								  FROM
									(
									  SELECT
										m.conversation_lid, m.body, m.created_date,
										CONCAT(pu.first_name, ' ', pu.last_name) AS sender,
										mr.is_read, ml.sent_users
									  FROM message m
										INNER JOIN (
										  SELECT
											mm.conversation_lid,
											MAX(mm.created_date) as max_date,
											STRING_AGG(_pu.email, ', ') as sent_users
										  FROM message mm
											INNER JOIN message_recepient msr ON mm.id = msr.message_lid
											INNER JOIN public.user _pu ON _pu.id = msr.user_lid
											WHERE msr.participant_type_lid <> 2
										  GROUP BY conversation_lid
										) AS ml ON ml.conversation_lid = m.conversation_lid
										INNER JOIN message_recepient mr ON mr.message_lid = m.id
										INNER JOIN public.user pu ON pu.id = m.created_by
										AND m.created_date = ml.max_date
										AND mr.participant_type_lid = 2
										AND mr.active = TRUE AND m.active = TRUE
										AND pu.active = TRUE AND mr.user_lid = $1
									  ORDER BY
										m.created_date DESC
									) AS ss
									INNER JOIN conversation c ON c.id = ss.conversation_lid
									INNER JOIN conversation_participant cp ON cp.conversation_lid = c.id
								  WHERE
									cp.user_lid = $1
									AND c.active = true AND cp.active = true
								  ORDER BY
									ss.created_date DESC
								  LIMIT
									$3
								  OFFSET $2	
								) t
							);
  
  
   output_result['pagination'] := 
  					(
						SELECT 
						TO_JSONB(
							json_build_object(
								'total_count', t.total,
								'has_previous', CASE WHEN $2 > 0 THEN true ELSE false END,
								'has_next', CASE WHEN t.total > ($2 + $3) THEN true ELSE false END
							)
						) FROM
						(
								 SELECT
									COUNT(*) as total
								  FROM
									(
									  SELECT
										m.conversation_lid, m.body, m.created_date,
										CONCAT(pu.first_name, ' ', pu.last_name) AS sender,
										mr.is_read, ml.sent_users
									  FROM message m
										INNER JOIN (
										  SELECT
											mm.conversation_lid,
											MAX(mm.created_date) as max_date,
											STRING_AGG(_pu.email, ', ') as sent_users
										  FROM message mm
											INNER JOIN message_recepient msr ON mm.id = msr.message_lid
											INNER JOIN public.user _pu ON _pu.id = msr.user_lid
											WHERE msr.participant_type_lid <> 2
										  GROUP BY conversation_lid
										) AS ml ON ml.conversation_lid = m.conversation_lid
										INNER JOIN message_recepient mr ON mr.message_lid = m.id
										INNER JOIN public.user pu ON pu.id = m.created_by
										AND m.created_date = ml.max_date
										AND mr.participant_type_lid = 2
										AND mr.active = TRUE AND m.active = TRUE
										AND pu.active = TRUE AND mr.user_lid = $1
									  ORDER BY
										m.created_date DESC
									) AS ss
									INNER JOIN conversation c ON c.id = ss.conversation_lid
									INNER JOIN conversation_participant cp ON cp.conversation_lid = c.id
								  WHERE
									cp.user_lid = $1
									AND c.active = true AND cp.active = true

								) t
					);
					
RETURN output_result;

END
$_$;
 d   DROP FUNCTION public.get_sent_conversation(user_id integer, offset_val integer, limit_val integer);
       public          postgres    false                       1255    95107 3   get_starred_conversation(integer, integer, integer)    FUNCTION     [  CREATE FUNCTION public.get_starred_conversation(user_id integer, offset_val integer, limit_val integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$
DECLARE
	output_result JSONB := '{}';
BEGIN

	RAISE NOTICE 'USER >>>>>> %', $1 ;

  output_result['conversations'] :=
							  (
							  SELECT
								JSONB_AGG(TO_JSONB(t.*))
							  FROM
								(
								  SELECT 
									c.subject, c.id, ss.sender, ss.body as message,
									TO_CHAR(ss.created_date, 'Mon DD') as date,
									(
										SELECT COUNT(*) = 0 
										FROM message_recepient mr 
										INNER JOIN message m ON m.id = mr.message_lid
										WHERE mr.user_lid = $1 AND m.conversation_lid = c.id
										AND is_read = FALSE
									) as is_read, cp.is_starred, false as is_checked
								  FROM
									(
									  SELECT DISTINCT
										m.conversation_lid, m.body, m.created_date,
										CONCAT(pu.first_name, ' ', pu.last_name) AS sender
									  FROM message m
										INNER JOIN (
										  SELECT
											conversation_lid,
											MAX(created_date) as max_date
										  FROM message
										  GROUP BY conversation_lid
										) AS ml ON ml.conversation_lid = m.conversation_lid
										INNER JOIN message_recepient mr ON mr.message_lid = m.id
										INNER JOIN public.user pu ON pu.id = m.created_by
										AND m.created_date = ml.max_date
										AND mr.active = TRUE AND m.active = TRUE
										AND pu.active = TRUE AND mr.user_lid = $1
									  ORDER BY
										m.created_date DESC
									) AS ss
									INNER JOIN conversation c ON c.id = ss.conversation_lid
									INNER JOIN conversation_participant cp ON cp.conversation_lid = c.id
								  WHERE
									cp.user_lid = $1
									AND c.active = true AND cp.active = true
									AND cp.is_starred = TRUE
								  ORDER BY
									ss.created_date DESC
								  LIMIT
									$3
								  OFFSET $2
								) t
							);
  
   output_result['pagination'] := 
  					(
						SELECT 
						TO_JSONB(
							json_build_object(
								'total_count', (t.total),
								'has_previous', CASE WHEN $2 > 0 THEN true ELSE false END,
								'has_next', CASE WHEN t.total > ($2 + $3) THEN true ELSE false END
							)
						) FROM 
							(
								SELECT
									COUNT(*) as total
								  FROM
									(
									  SELECT
											m.conversation_lid, m.body, m.created_date,
											CONCAT(pu.first_name, ' ', pu.last_name) AS sender,
											mr.is_read
									  FROM message m
										INNER JOIN (
										  SELECT
											conversation_lid,
											MAX(created_date) as max_date
										  FROM message
										  GROUP BY conversation_lid
										) AS ml ON ml.conversation_lid = m.conversation_lid
										INNER JOIN message_recepient mr ON mr.message_lid = m.id
										INNER JOIN public.user pu ON pu.id = m.created_by
										AND m.created_date = ml.max_date
										AND mr.participant_type_lid <> 2
										AND mr.active = TRUE AND m.active = TRUE
										AND pu.active = TRUE AND mr.user_lid = $1
									  ORDER BY
										m.created_date DESC
									) AS ss
									INNER JOIN conversation c ON c.id = ss.conversation_lid
									INNER JOIN conversation_participant cp ON cp.conversation_lid = c.id
								  WHERE
									cp.user_lid = $1
									AND c.active = true AND cp.active = true AND cp.is_starred = TRUE
							) t
					);
RETURN output_result;

END
$_$;
 g   DROP FUNCTION public.get_starred_conversation(user_id integer, offset_val integer, limit_val integer);
       public          postgres    false                       1255    94365    update_profile(jsonb)    FUNCTION     �  CREATE FUNCTION public.update_profile(input_json jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE

-- '[{
--   "first_name": "Sameer",
--   "last_name": "Shaikh",
--   "designation": null,
--   "bio": null,
--   "profile_photo": null,
--   "file_id": null,
--   "user_lid": 2							 
-- }]'
	output_result JSONB := '{}';
BEGIN

	RAISE NOTICE '%', input_json;
	
	DROP TABLE IF EXISTS temp_user;
	CREATE TEMPORARY TABLE temp_user(
		user_lid INT NOT NULL,
		first_name VARCHAR(255) NOT NULL,
		last_name VARCHAR(255) NOT NULL,
		designation VARCHAR(255),
		bio VARCHAR(255),
		profile_photo VARCHAR(255),
		file_id VARCHAR(100)
	);

	INSERT INTO
        temp_user(user_lid,first_name,last_name,designation,bio,profile_photo,file_id)
      SELECT
        CAST(t ->> 'user_lid' AS int),
        	 t ->> 'first_name',
			 t ->> 'last_name',
			 t ->> 'designation',
			 t ->> 'bio',
			 t ->> 'profile_photo',
			 t ->> 'file_id'
		FROM jsonb_array_elements(input_json) AS t;
	
	RAISE NOTICE '%', (SELECT JSONB_AGG(TO_JSONB(t.*)) FROM (SELECT * FROM temp_user) t);
		UPDATE public.user pu 
		SET first_name = tu.first_name,
			last_name = tu.last_name,
			modified_date = CURRENT_TIMESTAMP
		FROM temp_user tu
		WHERE pu.id = tu.user_lid;
	
	
		UPDATE user_info ui
		SET designation = tu.designation,
			bio = tu.bio,
			profile_photo = CASE WHEN tu.profile_photo IS NOT NULL THEN tu.profile_photo ELSE ui.profile_photo END,
			file_id = CASE WHEN tu.profile_photo IS NOT NULL THEN tu.file_id ELSE ui.file_id END,
			modified_date = CURRENT_TIMESTAMP	
		FROM temp_user tu 
		WHERE tu.user_lid = ui.user_lid;

		
	output_result := '{"status": 200, "message": "Profile Updated Successfullt!"}';
	
	RETURN output_result;
END
$$;
 7   DROP FUNCTION public.update_profile(input_json jsonb);
       public          postgres    false            �            1259    84507    conversation    TABLE     G  CREATE TABLE public.conversation (
    id integer NOT NULL,
    subject character varying(300),
    created_by integer NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active boolean DEFAULT true
);
     DROP TABLE public.conversation;
       public         heap    postgres    false            �            1259    84506    conversation_id_seq    SEQUENCE     �   CREATE SEQUENCE public.conversation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.conversation_id_seq;
       public          postgres    false    224            �           0    0    conversation_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.conversation_id_seq OWNED BY public.conversation.id;
          public          postgres    false    223            �            1259    85389    conversation_participant    TABLE     �  CREATE TABLE public.conversation_participant (
    id integer NOT NULL,
    conversation_lid integer NOT NULL,
    user_lid integer NOT NULL,
    is_spam boolean DEFAULT false,
    is_archive boolean DEFAULT false,
    is_starred boolean DEFAULT false,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_by integer,
    active boolean DEFAULT true
);
 ,   DROP TABLE public.conversation_participant;
       public         heap    postgres    false            �            1259    85388    conversation_participant_id_seq    SEQUENCE     �   CREATE SEQUENCE public.conversation_participant_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.conversation_participant_id_seq;
       public          postgres    false    242            �           0    0    conversation_participant_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.conversation_participant_id_seq OWNED BY public.conversation_participant.id;
          public          postgres    false    241            �            1259    85023    folder_type    TABLE       CREATE TABLE public.folder_type (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    icon character varying(255),
    url character varying(200) NOT NULL,
    description character varying(255),
    active boolean DEFAULT true NOT NULL
);
    DROP TABLE public.folder_type;
       public         heap    postgres    false            �            1259    85022    folder_type_id_seq    SEQUENCE     �   CREATE SEQUENCE public.folder_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.folder_type_id_seq;
       public          postgres    false    236            �           0    0    folder_type_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.folder_type_id_seq OWNED BY public.folder_type.id;
          public          postgres    false    235            �            1259    84577    group    TABLE     p  CREATE TABLE public."group" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(500),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer NOT NULL,
    modified_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active boolean DEFAULT true
);
    DROP TABLE public."group";
       public         heap    postgres    false            �            1259    84576    group_id_seq    SEQUENCE     �   CREATE SEQUENCE public.group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.group_id_seq;
       public          postgres    false    226            �           0    0    group_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.group_id_seq OWNED BY public."group".id;
          public          postgres    false    225            �            1259    84885    group_member    TABLE     �  CREATE TABLE public.group_member (
    id integer NOT NULL,
    group_lid integer NOT NULL,
    user_lid integer NOT NULL,
    created_by integer NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_by integer NOT NULL,
    modified_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active boolean DEFAULT true
);
     DROP TABLE public.group_member;
       public         heap    postgres    false            �            1259    84884    group_member_id_seq    SEQUENCE     �   CREATE SEQUENCE public.group_member_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.group_member_id_seq;
       public          postgres    false    228            �           0    0    group_member_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.group_member_id_seq OWNED BY public.group_member.id;
          public          postgres    false    227            �            1259    84972    label_conversation    TABLE     O  CREATE TABLE public.label_conversation (
    id integer NOT NULL,
    label_lid integer NOT NULL,
    conversation_lid integer NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active boolean DEFAULT true
);
 &   DROP TABLE public.label_conversation;
       public         heap    postgres    false            �            1259    84971    label_conversation_id_seq    SEQUENCE     �   CREATE SEQUENCE public.label_conversation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.label_conversation_id_seq;
       public          postgres    false    234            �           0    0    label_conversation_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.label_conversation_id_seq OWNED BY public.label_conversation.id;
          public          postgres    false    233            �            1259    85251    message    TABLE     k  CREATE TABLE public.message (
    id integer NOT NULL,
    conversation_lid integer NOT NULL,
    body text,
    parent_id integer,
    created_by integer NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active boolean DEFAULT true
);
    DROP TABLE public.message;
       public         heap    postgres    false            �            1259    95007    message_attachment    TABLE     `  CREATE TABLE public.message_attachment (
    id integer NOT NULL,
    message_lid integer NOT NULL,
    file_name character varying(255) NOT NULL,
    file_type character varying(100) NOT NULL,
    file_path character varying(255) NOT NULL,
    file_id character varying(255) NOT NULL,
    file_size bigint NOT NULL,
    active boolean DEFAULT true
);
 &   DROP TABLE public.message_attachment;
       public         heap    postgres    false            �            1259    95006    message_attachment_id_seq    SEQUENCE     �   CREATE SEQUENCE public.message_attachment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.message_attachment_id_seq;
       public          postgres    false    244            �           0    0    message_attachment_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.message_attachment_id_seq OWNED BY public.message_attachment.id;
          public          postgres    false    243            �            1259    85250    message_id_seq    SEQUENCE     �   CREATE SEQUENCE public.message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.message_id_seq;
       public          postgres    false    238            �           0    0    message_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.message_id_seq OWNED BY public.message.id;
          public          postgres    false    237            �            1259    85348    message_recepient    TABLE     �  CREATE TABLE public.message_recepient (
    id integer NOT NULL,
    message_lid integer NOT NULL,
    user_lid integer NOT NULL,
    participant_type_lid integer NOT NULL,
    group_lid integer,
    is_read boolean DEFAULT false,
    created_by integer NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_by integer NOT NULL,
    modified_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active boolean DEFAULT true
);
 %   DROP TABLE public.message_recepient;
       public         heap    postgres    false            �            1259    85347    message_recepient_id_seq    SEQUENCE     �   CREATE SEQUENCE public.message_recepient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.message_recepient_id_seq;
       public          postgres    false    240            �           0    0    message_recepient_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.message_recepient_id_seq OWNED BY public.message_recepient.id;
          public          postgres    false    239            �            1259    84444    participant_type    TABLE     �   CREATE TABLE public.participant_type (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(255),
    active boolean DEFAULT true NOT NULL
);
 $   DROP TABLE public.participant_type;
       public         heap    postgres    false            �            1259    84443    participant_type_id_seq    SEQUENCE     �   CREATE SEQUENCE public.participant_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.participant_type_id_seq;
       public          postgres    false    220            �           0    0    participant_type_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.participant_type_id_seq OWNED BY public.participant_type.id;
          public          postgres    false    219            �            1259    84475    user    TABLE     �  CREATE TABLE public."user" (
    id integer NOT NULL,
    email character varying(50) NOT NULL,
    password character varying(255) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    modified_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_external boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL
);
    DROP TABLE public."user";
       public         heap    postgres    false            �            1259    84474    user_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.user_id_seq;
       public          postgres    false    222            �           0    0    user_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;
          public          postgres    false    221            �            1259    84933 	   user_info    TABLE     �  CREATE TABLE public.user_info (
    id integer NOT NULL,
    user_lid integer NOT NULL,
    designation character varying(100),
    bio character varying(255),
    profile_photo character varying(255),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    modified_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    active boolean DEFAULT true NOT NULL,
    file_id character varying(100) DEFAULT ''::character varying NOT NULL
);
    DROP TABLE public.user_info;
       public         heap    postgres    false            �            1259    84932    user_info_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.user_info_id_seq;
       public          postgres    false    230            �           0    0    user_info_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.user_info_id_seq OWNED BY public.user_info.id;
          public          postgres    false    229            �            1259    84950 
   user_label    TABLE     �  CREATE TABLE public.user_label (
    id integer NOT NULL,
    user_lid integer NOT NULL,
    name character varying(100) NOT NULL,
    color_hex character varying(7),
    created_by integer NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active boolean DEFAULT true
);
    DROP TABLE public.user_label;
       public         heap    postgres    false            �            1259    84949    user_label_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_label_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.user_label_id_seq;
       public          postgres    false    232            �           0    0    user_label_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.user_label_id_seq OWNED BY public.user_label.id;
          public          postgres    false    231            �           2604    84510    conversation id    DEFAULT     r   ALTER TABLE ONLY public.conversation ALTER COLUMN id SET DEFAULT nextval('public.conversation_id_seq'::regclass);
 >   ALTER TABLE public.conversation ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    224    223    224            �           2604    85392    conversation_participant id    DEFAULT     �   ALTER TABLE ONLY public.conversation_participant ALTER COLUMN id SET DEFAULT nextval('public.conversation_participant_id_seq'::regclass);
 J   ALTER TABLE public.conversation_participant ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    242    241    242            �           2604    85026    folder_type id    DEFAULT     p   ALTER TABLE ONLY public.folder_type ALTER COLUMN id SET DEFAULT nextval('public.folder_type_id_seq'::regclass);
 =   ALTER TABLE public.folder_type ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    236    235    236            �           2604    84580    group id    DEFAULT     f   ALTER TABLE ONLY public."group" ALTER COLUMN id SET DEFAULT nextval('public.group_id_seq'::regclass);
 9   ALTER TABLE public."group" ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    226    225    226            �           2604    84888    group_member id    DEFAULT     r   ALTER TABLE ONLY public.group_member ALTER COLUMN id SET DEFAULT nextval('public.group_member_id_seq'::regclass);
 >   ALTER TABLE public.group_member ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    228    227    228            �           2604    84975    label_conversation id    DEFAULT     ~   ALTER TABLE ONLY public.label_conversation ALTER COLUMN id SET DEFAULT nextval('public.label_conversation_id_seq'::regclass);
 D   ALTER TABLE public.label_conversation ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    234    233    234            �           2604    85254 
   message id    DEFAULT     h   ALTER TABLE ONLY public.message ALTER COLUMN id SET DEFAULT nextval('public.message_id_seq'::regclass);
 9   ALTER TABLE public.message ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    237    238    238            �           2604    95010    message_attachment id    DEFAULT     ~   ALTER TABLE ONLY public.message_attachment ALTER COLUMN id SET DEFAULT nextval('public.message_attachment_id_seq'::regclass);
 D   ALTER TABLE public.message_attachment ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    244    243    244            �           2604    85351    message_recepient id    DEFAULT     |   ALTER TABLE ONLY public.message_recepient ALTER COLUMN id SET DEFAULT nextval('public.message_recepient_id_seq'::regclass);
 C   ALTER TABLE public.message_recepient ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    239    240    240            �           2604    84447    participant_type id    DEFAULT     z   ALTER TABLE ONLY public.participant_type ALTER COLUMN id SET DEFAULT nextval('public.participant_type_id_seq'::regclass);
 B   ALTER TABLE public.participant_type ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    220    219    220            �           2604    84478    user id    DEFAULT     d   ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);
 8   ALTER TABLE public."user" ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    221    222    222            �           2604    84936    user_info id    DEFAULT     l   ALTER TABLE ONLY public.user_info ALTER COLUMN id SET DEFAULT nextval('public.user_info_id_seq'::regclass);
 ;   ALTER TABLE public.user_info ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    229    230    230            �           2604    84953    user_label id    DEFAULT     n   ALTER TABLE ONLY public.user_label ALTER COLUMN id SET DEFAULT nextval('public.user_label_id_seq'::regclass);
 <   ALTER TABLE public.user_label ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    231    232    232            �          0    84507    conversation 
   TABLE DATA           d   COPY public.conversation (id, subject, created_by, created_date, modified_date, active) FROM stdin;
    public          postgres    false    224   >�       �          0    85389    conversation_participant 
   TABLE DATA           �   COPY public.conversation_participant (id, conversation_lid, user_lid, is_spam, is_archive, is_starred, created_date, modified_date, modified_by, active) FROM stdin;
    public          postgres    false    242   n�       �          0    85023    folder_type 
   TABLE DATA           O   COPY public.folder_type (id, name, icon, url, description, active) FROM stdin;
    public          postgres    false    236   ��       �          0    84577    group 
   TABLE DATA           i   COPY public."group" (id, name, description, created_date, created_by, modified_date, active) FROM stdin;
    public          postgres    false    226   ��       �          0    84885    group_member 
   TABLE DATA           }   COPY public.group_member (id, group_lid, user_lid, created_by, created_date, modified_by, modified_date, active) FROM stdin;
    public          postgres    false    228   ��       �          0    84972    label_conversation 
   TABLE DATA           r   COPY public.label_conversation (id, label_lid, conversation_lid, created_date, modified_date, active) FROM stdin;
    public          postgres    false    234   7�       �          0    85251    message 
   TABLE DATA           y   COPY public.message (id, conversation_lid, body, parent_id, created_by, created_date, modified_date, active) FROM stdin;
    public          postgres    false    238   T�       �          0    95007    message_attachment 
   TABLE DATA           z   COPY public.message_attachment (id, message_lid, file_name, file_type, file_path, file_id, file_size, active) FROM stdin;
    public          postgres    false    244   �       �          0    85348    message_recepient 
   TABLE DATA           �   COPY public.message_recepient (id, message_lid, user_lid, participant_type_lid, group_lid, is_read, created_by, created_date, modified_by, modified_date, active) FROM stdin;
    public          postgres    false    240   -�       �          0    84444    participant_type 
   TABLE DATA           I   COPY public.participant_type (id, name, description, active) FROM stdin;
    public          postgres    false    220   ��       �          0    84475    user 
   TABLE DATA           ~   COPY public."user" (id, email, password, first_name, last_name, created_date, modified_date, is_external, active) FROM stdin;
    public          postgres    false    222   �       �          0    84933 	   user_info 
   TABLE DATA           �   COPY public.user_info (id, user_lid, designation, bio, profile_photo, created_date, modified_date, active, file_id) FROM stdin;
    public          postgres    false    230   ]�       �          0    84950 
   user_label 
   TABLE DATA           t   COPY public.user_label (id, user_lid, name, color_hex, created_by, created_date, modified_date, active) FROM stdin;
    public          postgres    false    232   �      �           0    0    conversation_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.conversation_id_seq', 144, true);
          public          postgres    false    223            �           0    0    conversation_participant_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.conversation_participant_id_seq', 198, true);
          public          postgres    false    241            �           0    0    folder_type_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.folder_type_id_seq', 8, true);
          public          postgres    false    235            �           0    0    group_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.group_id_seq', 1, true);
          public          postgres    false    225            �           0    0    group_member_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.group_member_id_seq', 3, true);
          public          postgres    false    227            �           0    0    label_conversation_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.label_conversation_id_seq', 1, true);
          public          postgres    false    233            �           0    0    message_attachment_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.message_attachment_id_seq', 1, false);
          public          postgres    false    243            �           0    0    message_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.message_id_seq', 122, true);
          public          postgres    false    237            �           0    0    message_recepient_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.message_recepient_id_seq', 212, true);
          public          postgres    false    239            �           0    0    participant_type_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.participant_type_id_seq', 5, true);
          public          postgres    false    219            �           0    0    user_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.user_id_seq', 100, true);
          public          postgres    false    221            �           0    0    user_info_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.user_info_id_seq', 100, true);
          public          postgres    false    229            �           0    0    user_label_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.user_label_id_seq', 35, true);
          public          postgres    false    231                        2606    85401 6   conversation_participant conversation_participant_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.conversation_participant
    ADD CONSTRAINT conversation_participant_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.conversation_participant DROP CONSTRAINT conversation_participant_pkey;
       public            postgres    false    242            �           2606    84515    conversation conversation_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.conversation
    ADD CONSTRAINT conversation_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.conversation DROP CONSTRAINT conversation_pkey;
       public            postgres    false    224            �           2606    85037     folder_type folder_type_icon_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.folder_type
    ADD CONSTRAINT folder_type_icon_key UNIQUE (icon);
 J   ALTER TABLE ONLY public.folder_type DROP CONSTRAINT folder_type_icon_key;
       public            postgres    false    236            �           2606    85033     folder_type folder_type_name_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.folder_type
    ADD CONSTRAINT folder_type_name_key UNIQUE (name);
 J   ALTER TABLE ONLY public.folder_type DROP CONSTRAINT folder_type_name_key;
       public            postgres    false    236            �           2606    85031    folder_type folder_type_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.folder_type
    ADD CONSTRAINT folder_type_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.folder_type DROP CONSTRAINT folder_type_pkey;
       public            postgres    false    236            �           2606    85035    folder_type folder_type_url_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.folder_type
    ADD CONSTRAINT folder_type_url_key UNIQUE (url);
 I   ALTER TABLE ONLY public.folder_type DROP CONSTRAINT folder_type_url_key;
       public            postgres    false    236            �           2606    84893    group_member group_members_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (id);
 I   ALTER TABLE ONLY public.group_member DROP CONSTRAINT group_members_pkey;
       public            postgres    false    228            �           2606    84589    group group_name_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public."group"
    ADD CONSTRAINT group_name_key UNIQUE (name);
 @   ALTER TABLE ONLY public."group" DROP CONSTRAINT group_name_key;
       public            postgres    false    226            �           2606    84587    group group_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public."group"
    ADD CONSTRAINT group_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public."group" DROP CONSTRAINT group_pkey;
       public            postgres    false    226            �           2606    84980 *   label_conversation label_conversation_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.label_conversation
    ADD CONSTRAINT label_conversation_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.label_conversation DROP CONSTRAINT label_conversation_pkey;
       public            postgres    false    234                       2606    95015 *   message_attachment message_attachment_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.message_attachment
    ADD CONSTRAINT message_attachment_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.message_attachment DROP CONSTRAINT message_attachment_pkey;
       public            postgres    false    244            �           2606    85261    message message_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.message DROP CONSTRAINT message_pkey;
       public            postgres    false    238            �           2606    85357 (   message_recepient message_recepient_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT message_recepient_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT message_recepient_pkey;
       public            postgres    false    240            �           2606    84452 *   participant_type participant_type_name_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.participant_type
    ADD CONSTRAINT participant_type_name_key UNIQUE (name);
 T   ALTER TABLE ONLY public.participant_type DROP CONSTRAINT participant_type_name_key;
       public            postgres    false    220            �           2606    84450 &   participant_type participant_type_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.participant_type
    ADD CONSTRAINT participant_type_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.participant_type DROP CONSTRAINT participant_type_pkey;
       public            postgres    false    220            �           2606    84488    user unique_email 
   CONSTRAINT     O   ALTER TABLE ONLY public."user"
    ADD CONSTRAINT unique_email UNIQUE (email);
 =   ALTER TABLE ONLY public."user" DROP CONSTRAINT unique_email;
       public            postgres    false    222            �           2606    84943    user_info unique_user_fkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.user_info
    ADD CONSTRAINT unique_user_fkey UNIQUE (user_lid);
 D   ALTER TABLE ONLY public.user_info DROP CONSTRAINT unique_user_fkey;
       public            postgres    false    230            �           2606    84958    user_label user_label_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.user_label
    ADD CONSTRAINT user_label_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.user_label DROP CONSTRAINT user_label_pkey;
       public            postgres    false    232            �           2606    84486    user user_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public."user" DROP CONSTRAINT user_pkey;
       public            postgres    false    222                       2606    84981 (   label_conversation conversation_label_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.label_conversation
    ADD CONSTRAINT conversation_label_fk FOREIGN KEY (conversation_lid) REFERENCES public.conversation(id);
 R   ALTER TABLE ONLY public.label_conversation DROP CONSTRAINT conversation_label_fk;
       public          postgres    false    224    3302    234                       2606    85402 4   conversation_participant conversation_participant_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.conversation_participant
    ADD CONSTRAINT conversation_participant_fk FOREIGN KEY (conversation_lid) REFERENCES public.conversation(id);
 ^   ALTER TABLE ONLY public.conversation_participant DROP CONSTRAINT conversation_participant_fk;
       public          postgres    false    242    224    3302                       2606    84590    group group_created_fk    FK CONSTRAINT     {   ALTER TABLE ONLY public."group"
    ADD CONSTRAINT group_created_fk FOREIGN KEY (created_by) REFERENCES public."user"(id);
 B   ALTER TABLE ONLY public."group" DROP CONSTRAINT group_created_fk;
       public          postgres    false    226    3300    222                       2606    84894    group_member group_members_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT group_members_fk FOREIGN KEY (group_lid) REFERENCES public."group"(id);
 G   ALTER TABLE ONLY public.group_member DROP CONSTRAINT group_members_fk;
       public          postgres    false    226    3306    228                       2606    84986 (   label_conversation label_conversation_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.label_conversation
    ADD CONSTRAINT label_conversation_fk FOREIGN KEY (label_lid) REFERENCES public.user_label(id);
 R   ALTER TABLE ONLY public.label_conversation DROP CONSTRAINT label_conversation_fk;
       public          postgres    false    234    232    3312            
           2606    84961    user_label label_created_by_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_label
    ADD CONSTRAINT label_created_by_fk FOREIGN KEY (created_by) REFERENCES public."user"(id);
 H   ALTER TABLE ONLY public.user_label DROP CONSTRAINT label_created_by_fk;
       public          postgres    false    232    222    3300                       2606    95016 (   message_attachment message_attachment_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_attachment
    ADD CONSTRAINT message_attachment_fk FOREIGN KEY (message_lid) REFERENCES public.message(id);
 R   ALTER TABLE ONLY public.message_attachment DROP CONSTRAINT message_attachment_fk;
       public          postgres    false    244    238    3324                       2606    85262    message message_conversation_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_conversation_fk FOREIGN KEY (conversation_lid) REFERENCES public.conversation(id);
 I   ALTER TABLE ONLY public.message DROP CONSTRAINT message_conversation_fk;
       public          postgres    false    3302    224    238                       2606    85358 )   message_recepient message_conversation_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT message_conversation_fk FOREIGN KEY (message_lid) REFERENCES public.message(id);
 S   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT message_conversation_fk;
       public          postgres    false    240    3324    238                       2606    85363 "   message_recepient message_group_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT message_group_fk FOREIGN KEY (group_lid) REFERENCES public."group"(id);
 L   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT message_group_fk;
       public          postgres    false    240    226    3306                       2606    85272    message message_parent_fk    FK CONSTRAINT     |   ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_parent_fk FOREIGN KEY (parent_id) REFERENCES public.message(id);
 C   ALTER TABLE ONLY public.message DROP CONSTRAINT message_parent_fk;
       public          postgres    false    3324    238    238                       2606    85368 -   message_recepient message_participant_type_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT message_participant_type_fk FOREIGN KEY (participant_type_lid) REFERENCES public.participant_type(id);
 W   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT message_participant_type_fk;
       public          postgres    false    220    240    3296                       2606    84516 !   conversation user_conversation_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.conversation
    ADD CONSTRAINT user_conversation_fk FOREIGN KEY (created_by) REFERENCES public."user"(id);
 K   ALTER TABLE ONLY public.conversation DROP CONSTRAINT user_conversation_fk;
       public          postgres    false    222    3300    224                       2606    85407 9   conversation_participant user_conversation_participant_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.conversation_participant
    ADD CONSTRAINT user_conversation_participant_fk FOREIGN KEY (user_lid) REFERENCES public."user"(id);
 c   ALTER TABLE ONLY public.conversation_participant DROP CONSTRAINT user_conversation_participant_fk;
       public          postgres    false    242    3300    222                       2606    85373 )   message_recepient user_created_message_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT user_created_message_fk FOREIGN KEY (created_by) REFERENCES public."user"(id);
 S   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT user_created_message_fk;
       public          postgres    false    222    240    3300            	           2606    84944    user_info user_details_fkey    FK CONSTRAINT     |   ALTER TABLE ONLY public.user_info
    ADD CONSTRAINT user_details_fkey FOREIGN KEY (user_lid) REFERENCES public."user"(id);
 E   ALTER TABLE ONLY public.user_info DROP CONSTRAINT user_details_fkey;
       public          postgres    false    222    3300    230                       2606    84899 "   group_member user_group_created_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT user_group_created_fk FOREIGN KEY (created_by) REFERENCES public."user"(id);
 L   ALTER TABLE ONLY public.group_member DROP CONSTRAINT user_group_created_fk;
       public          postgres    false    228    222    3300                       2606    84904    group_member user_group_fk    FK CONSTRAINT     {   ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT user_group_fk FOREIGN KEY (user_lid) REFERENCES public."user"(id);
 D   ALTER TABLE ONLY public.group_member DROP CONSTRAINT user_group_fk;
       public          postgres    false    3300    222    228                       2606    84909 #   group_member user_group_modified_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT user_group_modified_fk FOREIGN KEY (modified_by) REFERENCES public."user"(id);
 M   ALTER TABLE ONLY public.group_member DROP CONSTRAINT user_group_modified_fk;
       public          postgres    false    3300    228    222                       2606    84966    user_label user_label_fk    FK CONSTRAINT     y   ALTER TABLE ONLY public.user_label
    ADD CONSTRAINT user_label_fk FOREIGN KEY (user_lid) REFERENCES public."user"(id);
 B   ALTER TABLE ONLY public.user_label DROP CONSTRAINT user_label_fk;
       public          postgres    false    222    3300    232                       2606    85267    message user_message_fk    FK CONSTRAINT     z   ALTER TABLE ONLY public.message
    ADD CONSTRAINT user_message_fk FOREIGN KEY (created_by) REFERENCES public."user"(id);
 A   ALTER TABLE ONLY public.message DROP CONSTRAINT user_message_fk;
       public          postgres    false    238    222    3300                       2606    85378 *   message_recepient user_message_modified_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT user_message_modified_fk FOREIGN KEY (modified_by) REFERENCES public."user"(id);
 T   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT user_message_modified_fk;
       public          postgres    false    240    222    3300                       2606    85383 -   message_recepient user_message_participant_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT user_message_participant_fk FOREIGN KEY (user_lid) REFERENCES public."user"(id);
 W   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT user_message_participant_fk;
       public          postgres    false    240    3300    222                       2606    85412 6   conversation_participant user_modified_conversation_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.conversation_participant
    ADD CONSTRAINT user_modified_conversation_fk FOREIGN KEY (modified_by) REFERENCES public."user"(id);
 `   ALTER TABLE ONLY public.conversation_participant DROP CONSTRAINT user_modified_conversation_fk;
       public          postgres    false    3300    222    242            �      x�}�Mr�0F��)t<���wh�3t�M����@����n(0^?�Y�'2N���OݸS��,�-��\"N��(�*�2^-�~�e�����L�^���_������c���QGF���f��ߔ�@�����!Y�#��B�.�~ݍ��6��]2(��q�,�h�����8'�����D!i��\C⠿�hl�R�	}�̔(w�;���|n�q�Q����i��N��z?�-��I�k��"�Ъh���+�0��q��1���� ��rQ��e���7�4�/P�      �   ]  x���]��0���S�5��dIg��=A��*N��1tYB`̗�D,Ȳ���/�;��H!���;�$\+z]�R������g��Pe�MH�8=�'����L�=I�t"}�ɳ��CO-*b!}!Q��]�DU�$M?sz�o����૧�\�kϧ��{:%>�7ʐ Ċ+ �N��w܆$	� (N &�$��d-��SRj=�l#	�hMWS�{J"�0q�,�8��ͤ�:�I�P��FA}Hr�A���CPIb�j;N�At*uO�*,ÎB�:J�Yi&�^v����3V>�%5n���c\) ��0�N}�\���� �\�6>�ϼ�~�I���� �/ί���v�M      �   �   x�M�K� ���p���ĸ��ݠ mb[�#�� 0���n�c� �fi��S��.x�ڕ����� �tN��}jb�o�zB/�����=\�|5�r�]��s�*����xUxva��.RP�w�Npwҏ�\Dbz��[����"�Сc�}2u�      �   T   x�3��OK�LNUp/�/-@�(��)姥g��%�(���q���*ZXYX����s�,����� T��      �   ;   x�3�4C##c]c]#SC+c+c3=SScKC3��%\F �`T`L�	1z\\\ lz$      �      x������ � �      �   �  x�}�MO�0��ɯ�^ay��-qh
M[AժZ�D\���D��,E�z�9l������w��;������>��؏�y�7���쭜���˨�����U�0� B�⒫K���S�Y���@PV��'5KnB��H�$g)�:��"�F�$OQD1�d�CѾ?mD������Z��V;4N
f�2ʄ$�AS�eX���N�C��j�����_0
�Dfp�C�ϐD ����o��āq LY+4�$�5���_��'in�p�-	�h9p�<ݞ7����X\ wR9�L&&	I�EN\�˶�7���k,׳��U���󸾫v8o��nӬ���tG��UZ���jێ_���?���ecU���?##+@K�f(���wɻr)�./���L(� (y
}_)�Z��'��f�����kII�����[��      �      x������ � �      �   �  x���Kr�0DךS�f�C�C�^���4�xFb�rVZ4��h :l��ц����+į �@/(�қ��Z���'y�裩���ł���lYtnb�{�;L�����fx�1|��/�5P�2�,f��;O^2w�G���~��Ԝd�i.a=Ro����7��j鴶d-�2��?�=��=�o���<������>r���,��!8-r�<uFǵX0������?�Q����*��>]&�ا���`8���@]��(�,���UP����/(�{:C.��=���5�������M�y�_����ޛ�S^ͬ]}747�Γ�X��#��v~;��%�����|�-�y�Z,c<�����*f!�۠qtT��}�U1�.�sw��H�Vn6u%ۿ�<�'�p�?I� �H����v��D�      �   )   x�3�,����,�2�L+�υ��9��!,�$3F���       �   0  x��\Ms�8=w~����H����1q&�';5٩�K�I� @�d��O��gn�[����J�e�{O��k��[��vj�7L�Vr��z��m��z���ۦ���:i�ϛ<���:��e³|��<�E���kLx^4E���u��u��m�.�M]b�)Ҥ�[L1�g�.M�"��p��d�&ϫ�Zc^�qUg����}�uQ6��nWY^���.O�|W%�hjx��n��:ݼ_oާ�������f�*�b����_5��e�K��V[f;=��^�D��B��=��J=�9c�����Jp�J	�J���`�3|�P��i����������Bʜ��iM���+�;��i! B��lE��=De�Ս�%��·� �5�Me�&��y-T$<�TsZ|�	���Z!�zWBG@��I(Z��)%BZG�i^2�j�N�FO�<_(�(��a�B�^��b��m�M$:<��8<���aÈ�S�&�cQ����y��I(+i��l�y�Xlѯ�P)�/�CT�%rY�a�U_��W��d���x��� k�T�`y�D�F�;x~"��R����d����$����%ⵇB� ��(jn+-oxչt�"���W��봓n�8h�����Z.偕�>9�����9��bX������Q9K��g�9�2�x"B
���i�Hf�B���R���G��C$؀3�����Α�7=pxZ���߂�PJ�UL���7�����]���f�"BH��`5k�^�2�WT$Y'\{�!�w i/Ԧـ#����ߋ� ?-�C����
2��_�a���I_�O9ܽ��aC�-��7�x4x�/�C(�s<�v�b1�h(,��o�Pї��O�������Ar�}\��� m��JLl�5FWuMf��{�)�v����Fh\���=���h��hO�F!�~�{���@�+3���a!���V(E�j~e�VR�7��^�3���~ȹX�nV�C�w�������,׊�SJ</��yA��u�ޯw?%��m��Ң�PR\���'�z��.� ��p狃�{�A �ђ1����6�8����������OI�!K>d�j���vs����#̌�B)+<�����,KT?��E�h��MPV�}��$B��A��Ai�I�쀲��H����3Z��Д�j�$oّ�?_�����}�����NR6�XNR��`����z �����dú��R6P�Ti2˴�<���K�<�2wnU,Q����}�)ғ�:4u�1�߀�E���6�(���Q�����7��7_��&�;�+�/�/Bt��"��(\�%9�p%�|z���J�W�)8>�M&D�T=qKeN������X�դ���;�^&AVaN
�p^��h��>����5�?D�쌽.5�Տd��Su%�TG"����B�{�7'�#�dV�����\�]i�F �	m��:�Ѣ���ڟ㉤b�X�a�`E��]���fX?p�CRG־����Ux�!��%R><q)ά�M/dLx$��sǛf�4g!Z��$�V����i�Z���)'�.Bd؀,�:`#�������h�Z�u��{��)��ډrtLX;M�Hp'���!�3���'">���0×�;����zR�>�-\����>D���xҳ�R��������%a��{DӠ��<�D�Xb��6�+���$D��A�V�NV�A+�t,���1�g!�A�P�Ӈ��V�1�Xj�[4'����*{�@m+<92O��eI!u���g�!�S8�9��>��:�m�3�k��#�4r���Վ�S��0�����֦���?D�-��k�K�ٱ�ݣ����!��CT�`x��^b�F�Z����v��\q�ǎ�V{�W&�&������!�`%�P��LK=9��J�&����TE�p!���e�iL������#�g�91~_��hP��_%�<9�ӤjnZ���I��!��u��CN~��͎��W�U5����s��G��4}��#w�樅M��^�n����!��4H;��h׉��G����y��ώ�3�t�������@�1�d��<pN�IT$����(�Ї��Ay�-���ҿ�9o����g�!
� q�Su�UZNC)0�p�]���
�[�s0:~U�e���c	�']kI���?D�=���㦜ӌr�P�ũ��#()�SZЇh@�q�ͅ"+��H�5W�4A?p#9<����_�sV�6iΚ*�d-\��a��>D������Lk�=�3�~촋��ԷN��н�Q#�#�ѭ�Ή�`'ы���Fr������o!Zl@�z�M��
�M�����,S��,BT��4���Q-�Jr���˫��x@s~j�x&"G�ùV�o���9���ZĒ.�'9��3�!vpB9�fN�9�F���f�c�I�>��E�2i�x�Y;�m$	�_
wo�CT��Aέ�iÎ���MM�Y���g�z�!����
L[v�K��%7�C�rF�A���.�mڱ���!���/F�N��lg�!$�M���ˈ�T0.G�6=#�a��_B� 9b�O\�C�/LG)j� �Pb]�%�eѳ��v��f�$d������0�a4F�T2?���O�cY�uI~�!<�kv=O6멏���j��#��g�!젪)ϜpNk�)�����/ko��C��X��g���� UOX݄5�{0������ґ�a��eh�_f�\���P@�gԤ/̏�VZ�2����G�!h��z-�8 9&�$����J�>���ջw����      �   m
  x��\Ks�8>w~�I�e�o1�L&��6�d��2U)E� �@���� ��FJeoUu�t*n���D�7ݸGj8�����=7��h�����\<܊����p�B��NT�y���;*�Vy��"�q�Y��tFi�͒E�Ge������QIM��ߣ�ߛ/��������~�"Nf�d'd�x����춈�$I����"'Q����m\��i�'4e|�(�:K��2�E�"�~�֑T��kCȝ0�q�/�V���4�O~V�$͋dQ��2�/��Ve���h��b�ޫ(���}�q�O��$Q�:�^g�m��e�L�-Y�F����X� �u��:m�N1g�#i��b�H���iPY�/��ԫF�&
��!��5pIR�EY��2OgU]V�4N�e��Y-9.@�,�g�����_�������+� iU2��N����2��ZYg�V��S�k�W���g���2�v�qE����Wf�B�>�gڿG�wT�Wע��P��i���lϙh��m� k��{-��!B	G�bʙPW#�g��*�������S
(����h8T�hif������τ"LZ��߮ɚ�D������1��3�9r�Q�1���\O3��P���DE�`���.١��N8aI�����������Rc��u
@�6Tlt_擸79i�H�i=&n���ܐµ����P^nv*� ?>��9o$�)�ˈ�l,��*C���n=�����P��\ �q�k�2�;��Q���f��L��P[,��AE�K�~r���T�|�*�|YEx�}w�AT�%�L ���&<E_7X6o(~qCc�@MG���H�8�&`��)��E�����p��ݳ��f� ��
U�P������!Gs�sd4�7�ժ6�QɄ�V��Q({���`�v��Ԥ�+�Ǥ�Q�	&(�0c�B睲S�}[Ct���W��/h^1�?T_��C��hlt0GS�!r��� Qa�N%%����B"��Q뵖k_�&���Km'~�1t�a#��ZH���{�(��B������@�ؖ6�?������u�@sW���=�gb7��;1���B/��x�ͬ�B�Z��N���!Ҩ ���VK@��(*e�ho�1��Gux��.�r�8^�?<�j�<+��~��P��Z�t�	(�����
�Cǧ��[�A]d�c��cM�0t�F�p�K�pa����Z�~~{7�xG�]��!N N���p���0��tgg��zknj̺�藖J�6�:��6ǻ�S�T��a�C�_����H5\���r]y�������dbH7l,y�^yL��P�@tXի@�N�r�h��Zb5��NX�}c�+cM�I��3����p�y��&�mej�I"H��C�ꮗ��8�e�K?��+�n���o����?�a�f����䒟��3ҿ'��xn���BU<���P���F�e��~�H��Jߢ�����[�v������j��p�G:e�Z'����(���=v}�$^�P�Z�㩑�c�m�U�[I(���n��}lc5wsZ�[�7��ʷ�?rۇ�����+�hI	(���A�n��`�j�ݐ�l!K��O�����Ĕ�H�vXԳM����^�'��nb��zm�Uu�Az�Ȧ�̵p����)N�P�RC�N�ј&���C���Xϻ�o7�t��U��^a'd�|�����Z��f(�9�4���$�6�/��T9��](���Q5|*��������cS^�����K@y·N㿕�&���a<��Q��#+�l��(�qމ���zp	(g7��]>�0v+���2����P !X��"Ȣ���YY�㑔iT��~���Rr-�o�QrTz�*$�]8gs�i�^�����ح��̠���$Uu��*Ke_s�0&j_K��:�zO���$3~(��a���X��Ҍ=U�©,�,;� g��M� �'��ۜ>ј�r]gβPN{�;n� i��+g����)BM� j�=GA��
��A���*�d%��������3���l;e�q�=��/ �j���8T�ۣV��t�c��@��ct���~dMk�P�Ǭ	�\�:)�;,�M��~�{�B���Y	�`@�A�Kyyv�"�!�/��;ŇN3,��k�g$v���J?��v���s�Ȉ˕�����>��#�-�I��ۀaN����wz/�7�a�I�G#l�ZB^^�R,�X\ٴ]�UC	p=�ԃ���<?�Ŋ����E���|�B��䒉��qԒ�!{J�2j�`��"�g�v��2Iu�-������3y���#=jwa>�p�P� ���h�׏���P�F��cZ�p���z<9��r��%7�A��%�/�:�iӍQ�cO��?.��pr+X�-(�������&�Ū�ʍs�J.� g{4�{��j��+é�h��@��%�\�����S�_3♐�!�cg/d�
I ��)�3����n�\��Q�0oB�>��|��c��a�܁_�K�CM\\��6vs�����7%�l�{��
8j�^��S6k��_JW��J9fݦ�6_�{������ׯ�����^�Ǡ;�C.��4{T�ȗ�chOR�"���1���Ǜ������&x��y��ŋ�κsN      �   �  x�}��n�0E��H������Z�R�e6��U�E���߁��ưB�{lό*_��ϳ�Z��F@�;�}���� �k�Y���w��1�f�.��*%4ֈW׃}1g���\���j#�q�^'0�����!���x�a�*�;���(�!�R*!��b�l���o�
�a*� )����H��y{P����H��%PZ����.�l�d��%�)�2[����K��G�*;M�&��qLTB�R�_����c���<1ۘ�DGD��Gf�������sD.� �%dm���+�t��Y$9Ҕ"����qV���ZBf��*@ɉ
�\7d��Mh��0�����:�Sy(dTg�N���8]̥�c���*!�0�L�:�;W���-��     