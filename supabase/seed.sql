-- Nardana Connect - Community Seed Data
-- ====================================================================
-- 1. VILLAGES
-- ====================================================================

insert into public.villages (id, name_mr, name_en, taluka, district, pincode, is_active) values
    ('a0000000-0000-0000-0000-000000000001', 'नरडाणा', 'Nardana', 'Shindkheda', 'Dhule', '425404', true),
    ('a0000000-0000-0000-0000-000000000002', 'वाघाळी', 'Waghadi', 'Shindkheda', 'Dhule', '425404', true),
    ('a0000000-0000-0000-0000-000000000003', 'होळ', 'Hol', 'Shindkheda', 'Dhule', '425404', true),
    ('a0000000-0000-0000-0000-000000000004', 'बेटावद', 'Betawad', 'Sindkheda', 'Dhule', '425403', true),
    ('a0000000-0000-0000-0000-000000000005', 'चिमठाणे', 'Chimthane', 'Shindkheda', 'Dhule', '425406', true),
    ('a0000000-0000-0000-0000-000000000006', 'वरडी', 'Vardi', 'Shindkheda', 'Dhule', '425404', true),
    ('a0000000-0000-0000-0000-000000000007', 'शिंदखेडा', 'Shindkheda', 'Shindkheda', 'Dhule', '425406', true)
on conflict (id) do nothing;

-- ====================================================================
-- 2. CATEGORIES
-- ====================================================================

insert into public.categories (id, name_mr, name_en, slug, group_type, icon, sort_order, is_active) values
    -- Home Services
    ('b0000000-0000-0000-0000-000000000001', 'इलेक्ट्रिशियन', 'Electrician', 'electrician', 'home_services', 'zap', 1, true),
    ('b0000000-0000-0000-0000-000000000002', 'प्लंबर', 'Plumber', 'plumber', 'home_services', 'wrench', 2, true),
    ('b0000000-0000-0000-0000-000000000003', 'सुतारकाम / कारपेंटर', 'Carpenter', 'carpenter', 'home_services', 'hammer', 3, true),
    ('b0000000-0000-0000-0000-000000000004', 'पेंटर', 'Painter', 'painter', 'home_services', 'paint-brush', 4, true),
    ('b0000000-0000-0000-0000-000000000005', 'गवंडी काम', 'Mason', 'mason', 'home_services', 'brick-wall', 5, true),
    ('b0000000-0000-0000-0000-000000000006', 'पाण्याचा टँकर', 'Water Tanker', 'water-tanker', 'home_services', 'droplet', 6, true),

    -- Shops
    ('b0000000-0000-0000-0000-000000000010', 'किराणा दुकान', 'Grocery Store', 'grocery', 'shops', 'shopping-cart', 10, true),
    ('b0000000-0000-0000-0000-000000000011', 'औषध दुकान / मेडिकल', 'Medical Store', 'medical-store', 'shops', 'pill', 11, true),
    ('b0000000-0000-0000-0000-000000000012', 'जनरल स्टोअर्स', 'General Store', 'general-store', 'shops', 'store', 12, true),
    ('b0000000-0000-0000-0000-000000000013', 'दूध डेअरी', 'Dairy', 'dairy', 'shops', 'milk', 13, true),
    ('b0000000-0000-0000-0000-000000000014', 'भाजीपाला दुकान', 'Vegetable Shop', 'vegetables', 'shops', 'carrot', 14, true),
    ('b0000000-0000-0000-0000-000000000015', 'हार्डवेअर आणि सिमेंट', 'Hardware & Building', 'hardware', 'shops', 'package', 15, true),

    -- Agriculture
    ('b0000000-0000-0000-0000-000000000020', 'ट्रॅक्टर भाड्याने', 'Tractor on Rent', 'tractor-rent', 'agriculture', 'tractor', 20, true),
    ('b0000000-0000-0000-0000-000000000021', 'जेसीबी / पोकलेन', 'JCB & Earthmover', 'jcb-services', 'agriculture', 'truck', 21, true),
    ('b0000000-0000-0000-0000-000000000022', 'हार्वेस्टर / कापणी यंत्र', 'Harvester', 'harvester', 'agriculture', 'scissors', 22, true),
    ('b0000000-0000-0000-0000-000000000023', 'शेती अवजारे', 'Agri Equipment', 'agri-equipment', 'agriculture', 'settings', 23, true),
    ('b0000000-0000-0000-0000-000000000024', 'खते व कीटकनाशके', 'Fertilizer & Seeds', 'fertilizers', 'agriculture', 'sprout', 24, true),

    -- Transport
    ('b0000000-0000-0000-0000-000000000030', 'ऑटो रिक्षा', 'Auto Rickshaw', 'auto-rickshaw', 'transport', 'car', 30, true),
    ('b0000000-0000-0000-0000-000000000031', 'टॅक्सी / ट्रॅव्हल्स', 'Taxi & Cabs', 'taxi-service', 'transport', 'navigation', 31, true),
    ('b0000000-0000-0000-0000-000000000032', 'मालवाहतूक वाहन', 'Goods Carrier', 'goods-transport', 'transport', 'truck', 32, true),

    -- Health
    ('b0000000-0000-0000-0000-000000000040', 'दवाखाना / डॉक्टर', 'Doctor & Clinic', 'doctors', 'health', 'heart-pulse', 40, true),
    ('b0000000-0000-0000-0000-000000000041', 'रुग्णालय', 'Hospital', 'hospital', 'health', 'cross', 41, true),
    ('b0000000-0000-0000-0000-000000000042', 'रुग्णवाहिका', 'Ambulance', 'ambulance', 'health', 'ambulance', 42, true),

    -- Education
    ('b0000000-0000-0000-0000-000000000050', 'शाळा व महाविद्यालये', 'Schools & Colleges', 'schools', 'education', 'graduation-cap', 50, true),
    ('b0000000-0000-0000-0000-000000000051', 'खाजगी शिकवणी', 'Tuition Classes', 'tuition', 'education', 'book-open', 51, true),
    ('b0000000-0000-0000-0000-000000000052', 'संगणक प्रशिक्षण केंद्र', 'Computer Institute', 'computer-classes', 'education', 'monitor', 52, true),

    -- Digital
    ('b0000000-0000-0000-0000-000000000060', 'महा-ई-सेवा व झेरॉक्स', 'CSC & Xerox Center', 'csc-center', 'digital', 'printer', 60, true),
    ('b0000000-0000-0000-0000-000000000061', 'मोबाईल दुरुस्ती', 'Mobile Repair', 'mobile-repair', 'digital', 'smartphone', 61, true),
    ('b0000000-0000-0000-0000-000000000062', 'संगणक दुरुस्ती', 'Computer Repair', 'computer-repair', 'digital', 'cpu', 62, true),

    -- Other
    ('b0000000-0000-0000-0000-000000000070', 'हॉटेल व खानावळ', 'Hotel & Dining', 'hotel-dining', 'other', 'utensils', 70, true),
    ('b0000000-0000-0000-0000-000000000071', 'मंडप व डेकोरेशन', 'Mandap & Catering', 'mandap-catering', 'other', 'music', 71, true),
    ('b0000000-0000-0000-0000-000000000072', 'गॅरेज व वाहन मेकॅनिक', 'Garage & Mechanic', 'vehicle-mechanic', 'other', 'tool', 72, true)
on conflict (id) do nothing;

-- ====================================================================
-- 3. EMERGENCY CONTACTS (Village Quick Access)
-- ====================================================================

insert into public.emergency_contacts (village_id, name_mr, name_en, category, phone, secondary_phone, sort_order) values
    ('a0000000-0000-0000-0000-000000000001', 'नरडाणा पोलीस दूरक्षेत्र', 'Nardana Police Outpost', 'Police', '112', '02566245100', 1),
    ('a0000000-0000-0000-0000-000000000001', 'शासकीय रुग्णवाहिका', 'Government Ambulance', 'Ambulance', '108', '102', 2),
    ('a0000000-0000-0000-0000-000000000001', 'महावितरण वीज तक्रार (MSEDCL)', 'Electricity Complaint Nardana', 'MSEDCL Electricity', '1912', '18002333435', 3),
    ('a0000000-0000-0000-0000-000000000001', 'ग्रामपंचायत कार्यालय नरडाणा', 'Gram Panchayat Office Nardana', 'Gram Panchayat', '02566258200', '', 4),
    ('a0000000-0000-0000-0000-000000000001', 'प्राथमिक आरोग्य केंद्र नरडाणा', 'Primary Health Centre Nardana', 'Hospital', '02566258210', '', 5),
    ('a0000000-0000-0000-0000-000000000001', 'सर्पमित्र हेल्पलाइन', 'Snake Rescuer Helpline', 'Snake Rescuer', '9421526400', '9822451200', 6),
    ('a0000000-0000-0000-0000-000000000001', 'अग्निशामक दल', 'Fire Emergency', 'Fire', '101', '', 7);

-- ====================================================================
-- 4. SAMPLE VERIFIED BUSINESSES & SERVICES
-- ====================================================================

insert into public.businesses (village_id, category_id, business_name_mr, business_name_en, owner_name, phone, whatsapp, address, description, status) values
    ('a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'जय भवानी इलेक्ट्रिकल वर्क्स', 'Jai Bhavani Electrical Works', 'सचिन पाटील', '9823012345', '9823012345', 'स्टेशन रोड, नरडाणा', 'घरगुती व शेती पंपाचे सर्व प्रकारचे वायरिंग व दुरुस्ती काम योग्य दरात करून मिळेल.', 'approved'),
    ('a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000010', 'महालक्ष्मी सुपर किराणा स्टोअर्स', 'Mahalaxmi Super Grocery', 'प्रमोद महाजन', '9422054321', '9422054321', 'मेन बाजारपेठ, नरडाणा', 'सर्व प्रकारचा दर्जेदार किराणा, कडधान्ये व घरगुती वस्तू वाजवी दरात उपलब्ध.', 'approved'),
    ('a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000011', 'धनवंतरी मेडिकल स्टोअर्स', 'Dhanvantari Medical Stores', 'डॉ. भूषण पाटील', '9890123456', '9890123456', 'ग्रामीण रुग्णालयासमोर, नरडाणा', 'सर्व ॲलोपॅथिक औषधे, व्हेटरनरी औषधे आणि प्राथमिक उपचार साहित्य उपलब्ध.', 'approved'),
    ('a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000020', 'किसान ट्रॅक्टर सर्व्हिसेस', 'Kisan Tractor Services', 'दिनेश चौधरी', '9765432100', '9765432100', 'वाघाळी फाटा, नरडाणा', 'नांगरणी, रोटाव्हेटर आणि पेरणीसाठी महिंद्रा ट्रॅक्टर वेळेवर उपलब्ध.', 'approved'),
    ('a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000060', 'आपले सरकार सेवा केंद्र व झेरॉक्स', 'Aaple Sarkar Seva Kendra', 'योगेश पवार', '9970112233', '9970112233', 'बस स्टँड जवळ, नरडाणा', '७/१२, ८-अ, आधार कार्ड, पॅन कार्ड, उत्पन्नाचा दाखला, सर्व ऑनलाईन शासकीय फॉर्म भरून मिळतील.', 'approved');

-- ====================================================================
-- 5. VILLAGE NOTICES
-- ====================================================================

insert into public.notices (village_id, title_mr, title_en, description_mr, description_en, published_date, priority, is_gram_panchayat, status) values
    ('a0000000-0000-0000-0000-000000000001', 'पाणी पुरवठा वेळापत्रक बदल', 'Drinking Water Schedule Update', 'नरडाणा ग्रामस्थांना कळविण्यात येते की पाईपलाईन दुरुस्तीच्या कामामुळे उद्या सकाळी ७ ते १० दरम्यानच पाणीपुरवठा केला जाईल.', 'All villagers are informed that due to pipeline maintenance work, water supply tomorrow will be from 7 AM to 10 AM only.', now(), 'high', true, 'published'),
    ('a0000000-0000-0000-0000-000000000001', 'मोफत डोळे तपासणी व मोतीबिंदू शिबीर', 'Free Eye Checkup & Cataract Camp', 'रविवार रोजी प्राथमिक आरोग्य केंद्र नरडाणा येथे सकाळी ९ ते दुपारी २ या वेळेत मोफत तपासणी शिबीर आयोजित करण्यात आले आहे.', 'Free eye checkup and cataract screening camp organized on Sunday at PHC Nardana from 9 AM to 2 PM.', now(), 'normal', false, 'published'),
    ('a0000000-0000-0000-0000-000000000001', 'महावितरण: वीज पुरवठा तात्पुरता खंडित', 'MSEDCL: Scheduled Power Outage', 'सबस्टेशनवरील नियमित दुरुस्ती कामामुळे गुरुवारी सकाळी ९ ते दुपारी २ वाजेपर्यंत वीज पुरवठा बंद राहील.', 'Scheduled power outage on Thursday 9 AM to 2 PM due to regular feeder maintenance work.', now(), 'high', false, 'published');

-- ====================================================================
-- 6. APP SETTINGS
-- ====================================================================

insert into public.app_settings (key, value, description) values
    ('platform_info', jsonb_build_object(
        'name', 'Nardana Connect',
        'tagline_mr', 'आपलं गाव, आपली डिजिटल ओळख!',
        'tagline_en', 'Our Village, Our Digital Identity!',
        'version', '1.0.0',
        'primary_color', '#123B67',
        'secondary_color', '#16A36A',
        'accent_color', '#F3B83F',
        'support_phone', '9421526400',
        'support_email', 'contact@nardanaconnect.in'
    ), 'Core branding and contact settings')
on conflict (key) do nothing;
