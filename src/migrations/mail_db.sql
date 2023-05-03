PGDMP     ,    6                {            mail_db    14.5    14.5 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    84383    mail_db    DATABASE     c   CREATE DATABASE mail_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'English_India.1252';
    DROP DATABASE mail_db;
                postgres    false                       1255    94243 8   add_label(integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.add_label(user_id integer, label_name character varying, color_hex character varying) RETURNS jsonb
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
       public          postgres    false                       1255    93234    create_conversation(jsonb)    FUNCTION     �	  CREATE FUNCTION public.create_conversation(input_json jsonb) RETURNS jsonb
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
       public          postgres    false                       1255    94229    delete_label(integer, integer)    FUNCTION     �  CREATE FUNCTION public.delete_label(user_id integer, label_id integer) RETURNS jsonb
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
       public          postgres    false            
           1255    85436    get_inbox_conversation(integer)    FUNCTION     c	  CREATE FUNCTION public.get_inbox_conversation(user_id integer) RETURNS jsonb
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
									50
								) t
							);
  
  
--   output_result['pagination'] := (SELECT TO_JSONB(t.*) FROM 
--                       (
--                           SELECT COUNT(*) as total_count
--                             FROM conversation c 
--                           INNER JOIN 
--                             message m
--                           ON m.conversation_lid = c.id
--                           INNER JOIN 
--                             message_recepient mr
--                           ON mr.message_lid = m.id
--                             WHERE mr.participant_type_lid <> 2
--                             AND mr.user_lid = user_id
--                             GROUP BY m.conversation_lid
--                       ) t);
  
  
RETURN output_result;

END
$_$;
 >   DROP FUNCTION public.get_inbox_conversation(user_id integer);
       public          postgres    false                       1255    95022    get_sent_conversation(integer)    FUNCTION     �  CREATE FUNCTION public.get_sent_conversation(user_id integer) RETURNS jsonb
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
									50
								) t
							);
  
  
RETURN output_result;

END
$_$;
 =   DROP FUNCTION public.get_sent_conversation(user_id integer);
       public          postgres    false                       1255    94926 !   get_starred_conversation(integer)    FUNCTION     p  CREATE FUNCTION public.get_starred_conversation(user_id integer) RETURNS jsonb
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
									50
								) t
							);
  
  
RETURN output_result;

END
$_$;
 @   DROP FUNCTION public.get_starred_conversation(user_id integer);
       public          postgres    false            	           1255    94365    update_profile(jsonb)    FUNCTION     �  CREATE FUNCTION public.update_profile(input_json jsonb) RETURNS jsonb
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
       public          postgres    false    248            �           0    0    message_attachment_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.message_attachment_id_seq OWNED BY public.message_attachment.id;
          public          postgres    false    247            �            1259    85250    message_id_seq    SEQUENCE     �   CREATE SEQUENCE public.message_id_seq
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
       public          postgres    false    241    242    242            �           2604    85026    folder_type id    DEFAULT     p   ALTER TABLE ONLY public.folder_type ALTER COLUMN id SET DEFAULT nextval('public.folder_type_id_seq'::regclass);
 =   ALTER TABLE public.folder_type ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    235    236    236            �           2604    84580    group id    DEFAULT     f   ALTER TABLE ONLY public."group" ALTER COLUMN id SET DEFAULT nextval('public.group_id_seq'::regclass);
 9   ALTER TABLE public."group" ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    226    225    226            �           2604    84888    group_member id    DEFAULT     r   ALTER TABLE ONLY public.group_member ALTER COLUMN id SET DEFAULT nextval('public.group_member_id_seq'::regclass);
 >   ALTER TABLE public.group_member ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    228    227    228            �           2604    84975    label_conversation id    DEFAULT     ~   ALTER TABLE ONLY public.label_conversation ALTER COLUMN id SET DEFAULT nextval('public.label_conversation_id_seq'::regclass);
 D   ALTER TABLE public.label_conversation ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    233    234    234            �           2604    85254 
   message id    DEFAULT     h   ALTER TABLE ONLY public.message ALTER COLUMN id SET DEFAULT nextval('public.message_id_seq'::regclass);
 9   ALTER TABLE public.message ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    237    238    238            �           2604    95010    message_attachment id    DEFAULT     ~   ALTER TABLE ONLY public.message_attachment ALTER COLUMN id SET DEFAULT nextval('public.message_attachment_id_seq'::regclass);
 D   ALTER TABLE public.message_attachment ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    247    248    248            �           2604    85351    message_recepient id    DEFAULT     |   ALTER TABLE ONLY public.message_recepient ALTER COLUMN id SET DEFAULT nextval('public.message_recepient_id_seq'::regclass);
 C   ALTER TABLE public.message_recepient ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    240    239    240            �           2604    84447    participant_type id    DEFAULT     z   ALTER TABLE ONLY public.participant_type ALTER COLUMN id SET DEFAULT nextval('public.participant_type_id_seq'::regclass);
 B   ALTER TABLE public.participant_type ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    220    219    220            �           2604    84478    user id    DEFAULT     d   ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);
 8   ALTER TABLE public."user" ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    221    222            �           2604    84936    user_info id    DEFAULT     l   ALTER TABLE ONLY public.user_info ALTER COLUMN id SET DEFAULT nextval('public.user_info_id_seq'::regclass);
 ;   ALTER TABLE public.user_info ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    230    229    230            �           2604    84953    user_label id    DEFAULT     n   ALTER TABLE ONLY public.user_label ALTER COLUMN id SET DEFAULT nextval('public.user_label_id_seq'::regclass);
 <   ALTER TABLE public.user_label ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    232    231    232            �          0    84507    conversation 
   TABLE DATA           d   COPY public.conversation (id, subject, created_by, created_date, modified_date, active) FROM stdin;
    public          postgres    false    224   ��       �          0    85389    conversation_participant 
   TABLE DATA           �   COPY public.conversation_participant (id, conversation_lid, user_lid, is_spam, is_archive, is_starred, created_date, modified_date, modified_by, active) FROM stdin;
    public          postgres    false    242   ��       �          0    85023    folder_type 
   TABLE DATA           O   COPY public.folder_type (id, name, icon, url, description, active) FROM stdin;
    public          postgres    false    236   �       �          0    84577    group 
   TABLE DATA           i   COPY public."group" (id, name, description, created_date, created_by, modified_date, active) FROM stdin;
    public          postgres    false    226   ��       �          0    84885    group_member 
   TABLE DATA           }   COPY public.group_member (id, group_lid, user_lid, created_by, created_date, modified_by, modified_date, active) FROM stdin;
    public          postgres    false    228   +�       �          0    84972    label_conversation 
   TABLE DATA           r   COPY public.label_conversation (id, label_lid, conversation_lid, created_date, modified_date, active) FROM stdin;
    public          postgres    false    234   v�       �          0    85251    message 
   TABLE DATA           y   COPY public.message (id, conversation_lid, body, parent_id, created_by, created_date, modified_date, active) FROM stdin;
    public          postgres    false    238   ��       �          0    95007    message_attachment 
   TABLE DATA           z   COPY public.message_attachment (id, message_lid, file_name, file_type, file_path, file_id, file_size, active) FROM stdin;
    public          postgres    false    248   0�       �          0    85348    message_recepient 
   TABLE DATA           �   COPY public.message_recepient (id, message_lid, user_lid, participant_type_lid, group_lid, is_read, created_by, created_date, modified_by, modified_date, active) FROM stdin;
    public          postgres    false    240   M�       �          0    84444    participant_type 
   TABLE DATA           I   COPY public.participant_type (id, name, description, active) FROM stdin;
    public          postgres    false    220   ��       �          0    84475    user 
   TABLE DATA           ~   COPY public."user" (id, email, password, first_name, last_name, created_date, modified_date, is_external, active) FROM stdin;
    public          postgres    false    222   �       �          0    84933 	   user_info 
   TABLE DATA           �   COPY public.user_info (id, user_lid, designation, bio, profile_photo, created_date, modified_date, active, file_id) FROM stdin;
    public          postgres    false    230   =�       �          0    84950 
   user_label 
   TABLE DATA           t   COPY public.user_label (id, user_lid, name, color_hex, created_by, created_date, modified_date, active) FROM stdin;
    public          postgres    false    232   g�       �           0    0    conversation_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.conversation_id_seq', 143, true);
          public          postgres    false    223            �           0    0    conversation_participant_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.conversation_participant_id_seq', 196, true);
          public          postgres    false    241            �           0    0    folder_type_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.folder_type_id_seq', 8, true);
          public          postgres    false    235            �           0    0    group_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.group_id_seq', 1, true);
          public          postgres    false    225            �           0    0    group_member_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.group_member_id_seq', 3, true);
          public          postgres    false    227            �           0    0    label_conversation_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.label_conversation_id_seq', 1, true);
          public          postgres    false    233            �           0    0    message_attachment_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.message_attachment_id_seq', 1, false);
          public          postgres    false    247            �           0    0    message_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.message_id_seq', 121, true);
          public          postgres    false    237            �           0    0    message_recepient_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.message_recepient_id_seq', 210, true);
          public          postgres    false    239            �           0    0    participant_type_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.participant_type_id_seq', 5, true);
          public          postgres    false    219            �           0    0    user_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.user_id_seq', 100, true);
          public          postgres    false    221            �           0    0    user_info_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.user_info_id_seq', 100, true);
          public          postgres    false    229            �           0    0    user_label_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.user_label_id_seq', 30, true);
          public          postgres    false    231                       2606    85401 6   conversation_participant conversation_participant_pkey 
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
       public            postgres    false    236                       2606    85033     folder_type folder_type_name_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.folder_type
    ADD CONSTRAINT folder_type_name_key UNIQUE (name);
 J   ALTER TABLE ONLY public.folder_type DROP CONSTRAINT folder_type_name_key;
       public            postgres    false    236                       2606    85031    folder_type folder_type_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.folder_type
    ADD CONSTRAINT folder_type_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.folder_type DROP CONSTRAINT folder_type_pkey;
       public            postgres    false    236                       2606    85035    folder_type folder_type_url_key 
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
       public            postgres    false    234                       2606    95015 *   message_attachment message_attachment_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.message_attachment
    ADD CONSTRAINT message_attachment_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.message_attachment DROP CONSTRAINT message_attachment_pkey;
       public            postgres    false    248                       2606    85261    message message_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.message DROP CONSTRAINT message_pkey;
       public            postgres    false    238            	           2606    85357 (   message_recepient message_recepient_pkey 
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
       public            postgres    false    222                       2606    84981 (   label_conversation conversation_label_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.label_conversation
    ADD CONSTRAINT conversation_label_fk FOREIGN KEY (conversation_lid) REFERENCES public.conversation(id);
 R   ALTER TABLE ONLY public.label_conversation DROP CONSTRAINT conversation_label_fk;
       public          postgres    false    234    224    3313            "           2606    85402 4   conversation_participant conversation_participant_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.conversation_participant
    ADD CONSTRAINT conversation_participant_fk FOREIGN KEY (conversation_lid) REFERENCES public.conversation(id);
 ^   ALTER TABLE ONLY public.conversation_participant DROP CONSTRAINT conversation_participant_fk;
       public          postgres    false    3313    224    242                       2606    84590    group group_created_fk    FK CONSTRAINT     {   ALTER TABLE ONLY public."group"
    ADD CONSTRAINT group_created_fk FOREIGN KEY (created_by) REFERENCES public."user"(id);
 B   ALTER TABLE ONLY public."group" DROP CONSTRAINT group_created_fk;
       public          postgres    false    226    222    3311                       2606    84894    group_member group_members_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT group_members_fk FOREIGN KEY (group_lid) REFERENCES public."group"(id);
 G   ALTER TABLE ONLY public.group_member DROP CONSTRAINT group_members_fk;
       public          postgres    false    3317    228    226                       2606    84986 (   label_conversation label_conversation_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.label_conversation
    ADD CONSTRAINT label_conversation_fk FOREIGN KEY (label_lid) REFERENCES public.user_label(id);
 R   ALTER TABLE ONLY public.label_conversation DROP CONSTRAINT label_conversation_fk;
       public          postgres    false    234    232    3323                       2606    84961    user_label label_created_by_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_label
    ADD CONSTRAINT label_created_by_fk FOREIGN KEY (created_by) REFERENCES public."user"(id);
 H   ALTER TABLE ONLY public.user_label DROP CONSTRAINT label_created_by_fk;
       public          postgres    false    232    3311    222            %           2606    95016 (   message_attachment message_attachment_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_attachment
    ADD CONSTRAINT message_attachment_fk FOREIGN KEY (message_lid) REFERENCES public.message(id);
 R   ALTER TABLE ONLY public.message_attachment DROP CONSTRAINT message_attachment_fk;
       public          postgres    false    3335    238    248                       2606    85262    message message_conversation_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_conversation_fk FOREIGN KEY (conversation_lid) REFERENCES public.conversation(id);
 I   ALTER TABLE ONLY public.message DROP CONSTRAINT message_conversation_fk;
       public          postgres    false    238    224    3313                       2606    85358 )   message_recepient message_conversation_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT message_conversation_fk FOREIGN KEY (message_lid) REFERENCES public.message(id);
 S   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT message_conversation_fk;
       public          postgres    false    3335    240    238                       2606    85363 "   message_recepient message_group_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT message_group_fk FOREIGN KEY (group_lid) REFERENCES public."group"(id);
 L   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT message_group_fk;
       public          postgres    false    3317    240    226                       2606    85272    message message_parent_fk    FK CONSTRAINT     |   ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_parent_fk FOREIGN KEY (parent_id) REFERENCES public.message(id);
 C   ALTER TABLE ONLY public.message DROP CONSTRAINT message_parent_fk;
       public          postgres    false    238    238    3335                       2606    85368 -   message_recepient message_participant_type_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT message_participant_type_fk FOREIGN KEY (participant_type_lid) REFERENCES public.participant_type(id);
 W   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT message_participant_type_fk;
       public          postgres    false    3307    220    240                       2606    84516 !   conversation user_conversation_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.conversation
    ADD CONSTRAINT user_conversation_fk FOREIGN KEY (created_by) REFERENCES public."user"(id);
 K   ALTER TABLE ONLY public.conversation DROP CONSTRAINT user_conversation_fk;
       public          postgres    false    222    224    3311            #           2606    85407 9   conversation_participant user_conversation_participant_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.conversation_participant
    ADD CONSTRAINT user_conversation_participant_fk FOREIGN KEY (user_lid) REFERENCES public."user"(id);
 c   ALTER TABLE ONLY public.conversation_participant DROP CONSTRAINT user_conversation_participant_fk;
       public          postgres    false    222    242    3311                       2606    85373 )   message_recepient user_created_message_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT user_created_message_fk FOREIGN KEY (created_by) REFERENCES public."user"(id);
 S   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT user_created_message_fk;
       public          postgres    false    222    240    3311                       2606    84944    user_info user_details_fkey    FK CONSTRAINT     |   ALTER TABLE ONLY public.user_info
    ADD CONSTRAINT user_details_fkey FOREIGN KEY (user_lid) REFERENCES public."user"(id);
 E   ALTER TABLE ONLY public.user_info DROP CONSTRAINT user_details_fkey;
       public          postgres    false    230    222    3311                       2606    84899 "   group_member user_group_created_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT user_group_created_fk FOREIGN KEY (created_by) REFERENCES public."user"(id);
 L   ALTER TABLE ONLY public.group_member DROP CONSTRAINT user_group_created_fk;
       public          postgres    false    228    222    3311                       2606    84904    group_member user_group_fk    FK CONSTRAINT     {   ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT user_group_fk FOREIGN KEY (user_lid) REFERENCES public."user"(id);
 D   ALTER TABLE ONLY public.group_member DROP CONSTRAINT user_group_fk;
       public          postgres    false    222    228    3311                       2606    84909 #   group_member user_group_modified_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT user_group_modified_fk FOREIGN KEY (modified_by) REFERENCES public."user"(id);
 M   ALTER TABLE ONLY public.group_member DROP CONSTRAINT user_group_modified_fk;
       public          postgres    false    3311    228    222                       2606    84966    user_label user_label_fk    FK CONSTRAINT     y   ALTER TABLE ONLY public.user_label
    ADD CONSTRAINT user_label_fk FOREIGN KEY (user_lid) REFERENCES public."user"(id);
 B   ALTER TABLE ONLY public.user_label DROP CONSTRAINT user_label_fk;
       public          postgres    false    3311    232    222                       2606    85267    message user_message_fk    FK CONSTRAINT     z   ALTER TABLE ONLY public.message
    ADD CONSTRAINT user_message_fk FOREIGN KEY (created_by) REFERENCES public."user"(id);
 A   ALTER TABLE ONLY public.message DROP CONSTRAINT user_message_fk;
       public          postgres    false    222    238    3311                        2606    85378 *   message_recepient user_message_modified_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT user_message_modified_fk FOREIGN KEY (modified_by) REFERENCES public."user"(id);
 T   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT user_message_modified_fk;
       public          postgres    false    240    3311    222            !           2606    85383 -   message_recepient user_message_participant_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.message_recepient
    ADD CONSTRAINT user_message_participant_fk FOREIGN KEY (user_lid) REFERENCES public."user"(id);
 W   ALTER TABLE ONLY public.message_recepient DROP CONSTRAINT user_message_participant_fk;
       public          postgres    false    240    3311    222            $           2606    85412 6   conversation_participant user_modified_conversation_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.conversation_participant
    ADD CONSTRAINT user_modified_conversation_fk FOREIGN KEY (modified_by) REFERENCES public."user"(id);
 `   ALTER TABLE ONLY public.conversation_participant DROP CONSTRAINT user_modified_conversation_fk;
       public          postgres    false    222    242    3311            �   �   x�}�MN�0F��)|�Z��q<�),�8%�TU+� ��������y�Ɵ��<O�}����! ހl�,JBJ�FTm��Cf�����2���Jo}�|p}�����7���뾋58%�(-T]qu�㾤�5�.$�ɳS�(���N���g+v�{��/�5t5#�<9e	-Tt�L��O�U�BՁ�-��^�Uٗ�) ��2.Uv7���z�w,A������y���������X�N���3*�Ю{q]�� ���      �   @  x���]j�0���S�+�o�g�sO������v�	l)	q@�c$Ϙ[x�#���A։�)dP&]�h�����r�?�䃨�vq`�I��6RHi�3M�ա�Ui�dC��}MY�)M5��҉�	��;e�`l�� y��1�����IA̍詤���[kzt'C��Z�v��	j�#wRԜ$��y�($ZX\�v����6P/���Vɓ��FːBh~Y#��(.�SPl3�Lq�*�~|4X1k�]V}��Pg1FW����vX�G�NH���r.y�-��T���dg�d����*{�9`�r����g�w��:���'�����      �   �   x�M�K� ���p���ĸ��ݠ mb[�#�� 0���n�c� �fi��S��.x�ڕ����� �tN��}jb�o�zB/�����=\�|5�r�]��s�*����xUxva��.RP�w�Npwҏ�\Dbz��[����"�Сc�}2u�      �   T   x�3��OK�LNUp/�/-@�(��)姥g��%�(���q���*ZXYX����s�,����� T��      �   ;   x�3�4C##c]c]#SC+c+c3=SScKC3��%\F �`T`L�	1z\\\ lz$      �      x������ � �      �   �  x�}��N�0E��W�GX�۱-u�������4�>P$Q�������"]��;� `$�٨z��~m�ț��b�Q��*�<h�g60�Y��Ew�"�Hg\�q<i��h0&(�� �\Ut�BV(�h�\�$O�����șAεI�"E:�M�E����W经��8R���� f��R�$��;̩�ǣt[�Zf×n?�F���*$y�$�5tr���0i)I����\>}I�ӿmI\���W!����о��t�
i92��$$9.r��=�����<ݭ�����~����/��5N�U{��8k�V��F#�yZo�j����wwW���:�2�����E��CA���J>%���{y�U�~��T��[|��8�&֌      �      x������ � �      �   }  x����q�0D�Rn�|�`���T��' %�}�x��K?,��`B��&�nӧ�_A�@���$'�h�c�>�9y �K�J�XXq���J��2'���mĀ�����5�*>h���em(I�73VÝ9ϙ��=��/�2%c)��9,7�����tV��[��b��Oc۝�y�d^�����}j�u	��,z�E��&�sɍK��h8�v4����1)11QҢ��e=��z�b"��*3F� 90Ya�#{��"�!��Ss��R�m.0M��¾�j�l�cp6"�Q	�q����\�E`k�{W/�H�4>��#���5�/f\�5x�y�}��{8N��y8�b,���>_���v�5�����ni��/)�)I      �   )   x�3�,����,�2�L+�υ��9��!,�$3F���       �     x��\Ms�8=w~����H}P�	��8������T��I�$D�P2��Aɓ����ŕ�˪��ݯ�ր=V�X�R��9-���j�]a�|�]������Ju�m�v��y��M��u�o���zW,1ž�g�ݒ�%.��X��j�K�V�<ۋ5��m�m���\�z��M�٦\EUVK,�.�fU�����z��n����v�b[de���R(�����C��W������z�a�\��n��_�����@���F��k��~�fq�J�3��[(�h�b�ZT�O����Z�WA� �C�z�NC"ԟ�Cx���`�l��Jl����F�_����{�O3��`I�F���X/+k��}*��N�]�G��-�w~,K�gJ�Np���G.h5�1
d�ҏ��̙qXH� �?F�i<��c��iIoDɤ���K$��Fkx�P�Qb}/���M�Je�F�Dtx@�
xx�#��%�яV���h�	���'���#؀Ӏ�آ�Q���_�Ǩ�J�\�*%��D�-��)� ;I��v��A�ᩴT`E�d�$ϭ�
[x~#��R�t-k��Ģ1�$��-�u�C��(�p��L���j}�^����pe���+�o"�ȗP��P��JC���O�H��L�1��cD�@M����x��`O�LD�{霄���ǈ���}���9�1(��t"�P��3�	V�-j�=�fpS"A����f�1��`+TJhM�{����?x��T�4���cD� R}�a�1�F%����$祅� <���Bc��z(�$@�^��iþ��V�������+��J�O�B*��~�;�K�iT�e8����Tp}A#��ܱ�#��e��9FK	`��}����|M~�D���b"_��3vB��?F��G��rd��H \qNf��{�9�ƵBX��T�����뿞��c4X��It'�Q����\e������9<�bTXC�H��]M�̿7ZI�I��w�D�����7 G� �µ(�v�뿿1ݓ�Z>&����g��_����l�a����|�*���CGeyK�&9�z�;��Y�!��<t
����
w�Ez����߀�S�y�Y�#�G���lc�,Q�`B���ʓ�1����C�$b�(�4�@��dKv@U�}"'_Ō2�?F��%�:�Vd�[V ?���ŉ�u���a�$���Y�z��>���z�>C��^�Sc��XۺT�j�*CV��U@�@6a�Ndk�O��J%
P;�<��� �6z�U��g���7m
�{�����w����m���KaS9q�����B F�5���q%��WmV�^J_
�:��4�X��x��H����'�Y6��(-�)�1+ja��R�m�ݐ��12l�}%Y�)۳ZN��Q�d&���
pv�4V?�yfO�J��'"�����B���7G"�dN�c���\�[�$ �	c��:���b�7<��ɬb�Tva�`E��]���eX�8�}�^�U9*z�\��OB�L0����H{�܊����̙C��*��3:���r��!%t�	�3�V�J�XK�xְ^pI�If���T]8��0��b�)'LYˤs㘈w�,�yFCC7��L����'�2�a���3O��C�%�����n�]��ǨP@w���:6:ʴ�l�~	'ա�"�1�w��hkT�瘩[Lr�V	-�ϟLb4	s$nՙ�g�덖ޤ���p}&st	<�>�m�f�����Sݢ=I=�7Dv�������<V�e"����G<������p?�~��j��ҘT��g�9����]A�O��^��cuO�?�'�;Ïa}j���e!;vav4�@�=���
�_F�s,���J?`�����QaFM��>������baS���j�~F#AN��Jm��Ȱ4�G�R�)�~�.j���vP�(ˎCvd��� 7��<��y���?F�=��U!ى�Fͅml؄N&9���יB���S;yѣ�^V�x�r*��Vͼ����"F��Aأ�.�һG�M�х=�@ F���"U�LS�I��Gi4���y�UȎ�%�|9o§���`O�1�zd�3_
���YR�#�ZT�r%��ǈ���$��T�3G�Nf��Z�����(�������W�2j�K��؄���奡���� ۣY�kFkA�J(<nyۇ3�vp2�^�r�7��&/Nu�@I��Ҍ>F����|"Ap���~V	x<�Pa����;c��U��Z�6eރ��3�	�&�΄;2��w,��PuCk|*�������
��5r8b_Z�H����$;9�S�Dv]��T)~2��b�3� \��U�v�p�>���7v~���L F����T��Q2�%E�5��IA����g"1rl@�8qMu��$�G�Y�2�tq?�>�)����A�y��tſ����S1;-����h��`M?4�$ȏa) ܽ��Qa55F�5;JK�'�����1����H��Nbް�X�T���*��
��}��%tn~���-;����8��b�kux��>F���$1?�K&Ԁ2�ͦie�ly��A��!�a�%?$x��OT���B�+h[,-���ԶkL�Y�ORql±���A�k8��F劅w�*iS*��)�/1"l O�}'�Mf�R�����|���}�[�8�N�f��e2�17�f��{�����Yn�'C!@��V7q=�X�JM�ش���c�N�ɾ'1�Ps���xx�&a�lmd*q\��(5D=�\BC*�H��2E�i"!p�
���#��g��ݻ��w�$      �   
  x��\K��6>��v�4ߢo�3N\'��l�%U.È �����m�z�"���������)O�__h ����=S�ɏ|å?~�ֹ޾_,�ӝ��?	w'�b�D��כ���B.�U�˚�N�yZ���J�r^4M�3V%q��YIM�oߢo��?��|�w���e�̗�<N�r�>K�'�]�I��^e��D��|w�*)�A�fq�����e]gi�,�j��ob��V֙�9���y-�6�����N8a��veU��<�WuY��8Y�W%K�Q�\�vE�*�W���O�]��������V%������o�P�Q��z�s�<�F.֊T��ݐF�5�Mj��#N�͈�\�@`��c7X����Hʸ�����n�'�2C��1���Z��
~s-��^J����F��V���y�B�J8�S΄�	��Z�/T������7�R@�:����FáZFK3�O��8|&a�*��vC6�%
]��&��� �a�p�9�׉����m��z���4�d���^��F0�A<�(;��!z�S���F�Dn{�	C�QK�1��� �C]�P�ݗ�$�MN��rZ���4�33R��������W���J@9Ϫa��vJ��2b)�oǻ�P���;OE?�u<T-��r����� ���GT&��Yƀ�:� 0�˥wP��R9��\k�$� �#TP����x�n�AT�%�L ���Lx��n�l�P��qQ|�m5����q?L�0T�S@��9v��!v���ٮAp-����|���C�����hjoX�Um4��	�m�m|���0��]C�35����1iuTr�	J8�X���y��v���u����	��W4��������!Ho46:������8��d����0T'���kT�!X���Fˍ�T�饶���gb#$�H�_�Bt%y��BWR���?lKw�|	U�P.�:Z����d��3�[DН�pv�}��z�d��f�b!u-r@�Wk�xȀ4* �Jt���
Pn��J@98�Gm��'��I������v�����S폘g%��/y�0UK�n=���y\�v���y
u!"�����qq|������Z`).�_�x�Qk�{�/�ȣ?�	��EX�Q���H�qq����Ƭ��~i�l+��os�;�1��A���9���X�����T��i(��7J�O�͞_H&v�t�n@���~(���4L�D�U�
T�d	(Ǎ��\K��>�	k�o�}e���>��~&b�|�n=O�ۤ���CM5I��|�G�����}�ǂ�qeٌ������۪{��	&h<�!�L.���;#�{6A���N�[�.T�@9��_o�E�[�gn���[��-�Q�j=�j?�^�?)�ƹ	g|�S�nep"� Ɏ�����Sק�I��u���9�i<��u@�P�e��r(��{L�c��[��Ѻ��=U�����=�LV��FKJ@9���ꆊ	FБ�V�������KH_OLL���j�E=ۄ-��z�z"�jF��=�kc��C]��SD6mdn�3\�tO�p�������Xw���4���P��z�Zl��[�zlpTy�{�����m_ctG��ke�����@��4����־$bR�Ԇt9�K�g��(6Z"��NMyCdZZ@Z�B�� �5:��V��v�����Fi/�/[b��m�w�0C�\����׏0�������;t��#@֣���0zC$eU�|�+���\���FT���>��
	dW�ٜvڼ}�� m%��!)3��$kIUj��R@9Ԝ����R�N��i>;	ÌJbt��vV�4cCOU�p*� �.;��cg�8H��	4�.g�O4f9��֙�� ��ၛf@�j�J�q�;e�P�<�Zq�QP����q�� ��C:Y	(����K�t�C�R���Ӹ�vrʗ�r3Y���?���Q+n:�1��q Xk�1��rvY���5��1k(��N���xf����R,�`ւ!�}��R�A��B��s��k��A���ø��Z��}b��ϡ�]@~� ��:2��re=Ţ8��O���qm�|�2`��� ?�>I�M�}R��l�������K(�76mWĀrÐE��\��!����{�_>bET|F$i�==_�P�g�d"�u�d~ŞӸ��>X�� �ե��LE��e�`�%��l��LG�=�HO��_؁�y'�6�5ȡ��3ZE���#�*���Q0��!�Gf�O�n����D��4(CU�����X�A0m�1*}��P���VWNn�eeq�[����d�Xw\��`U��� c�lO&u��\M8|m8�������~�߂�sn��kF<r0�x��⅌S!	$=era�x���O����>��M�ڧ�^.=�7l�{�k{�y��+�+[��n����_����$��xo_Q@G-���a�Wp�fMw��K骚<S)Ǭ�T�����c�w~�Z���MДV�+�4�`�y�����fO����{e�I*_ds7=b2�x��y��<Yݵ�o�?�޼y�_K9v      �   #  x�}��n�0Eg�+x�����/t(Pt��4�dhR��Ki�4��I8�H]��<���FX?[o@6�ʥ���{�y,��	��wa�Q��l��j���zr/�J�H�+^\��,-���
��*`�H��L&�Qa�>�Qf��@�ʥ�Lf������'���2�e�b5�ː�����dni��h(�|����n����lXBA-9��ْ����q�I�UY7iI S�����L�V<}~�ô�nd��51�e�ȁ��"���׸퓂����r�!��z��m��� 5��u     