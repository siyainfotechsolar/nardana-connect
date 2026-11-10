export interface Village {
  id: string;
  name_mr: string;
  name_en: string;
  taluka: string;
  district: string;
  pincode: string;
  is_active: boolean;
  created_at: string;
}

export interface Category {
  id: string;
  name_mr: string;
  name_en: string;
  slug: string;
  group_type: string;
  icon: string;
  sort_order: number;
  is_active: boolean;
}

export interface Business {
  id: string;
  business_name_mr: string;
  business_name_en: string;
  owner_name: string;
  phone: string;
  whatsapp?: string;
  address: string;
  description?: string;
  photos: string[];
  status: 'pending' | 'approved' | 'rejected';
  village_id: string;
  category_id: string;
  created_at: string;
}

export interface Job {
  id: string;
  job_title: string;
  company_name: string;
  employer_name: string;
  salary_range?: string;
  qualification?: string;
  experience?: string;
  job_location: string;
  contact_number: string;
  description: string;
  job_type: string;
  status: 'pending' | 'approved' | 'rejected' | 'expired';
  village_id: string;
  created_at: string;
}

export interface MarketplaceItem {
  id: string;
  title: string;
  category: string;
  price: number;
  description: string;
  images: string[];
  seller_name: string;
  phone: string;
  listing_type: 'SELL' | 'WANTED';
  status: 'pending' | 'approved' | 'rejected';
  is_sold: boolean;
  village_id: string;
  created_at: string;
}

export interface Notice {
  id: string;
  title_mr: string;
  title_en: string;
  description_mr: string;
  description_en: string;
  published_date: string;
  priority: 'normal' | 'high' | 'emergency';
  is_gram_panchayat: boolean;
  status: 'draft' | 'published' | 'expired' | 'archived';
  village_id: string;
  created_at: string;
}

export interface Advertisement {
  id: string;
  village_id: string;
  title_mr: string;
  title_en: string;
  description_mr?: string;
  description_en?: string;
  image_url: string;
  placement: 'home_carousel' | 'sponsored_card' | 'category_banner' | 'popup';
  category_id?: string;
  target_type: 'none' | 'business' | 'phone' | 'whatsapp' | 'url' | 'notice';
  target_id?: string;
  target_url?: string;
  phone?: string;
  whatsapp?: string;
  start_date: string;
  end_date: string;
  is_active: boolean;
  priority: number;
  impressions_count: number;
  clicks_count: number;
  advertiser_name?: string;
  advertiser_contact?: string;
  created_at: string;
  updated_at: string;
}

export interface AdvertisementEvent {
  id: string;
  advertisement_id: string;
  event_type: 'impression' | 'click';
  user_id?: string;
  device_info?: string;
  created_at: string;
}


