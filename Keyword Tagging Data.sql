------Keyword level Request response------------------------
SELECT 
LOWER(regexp_replace(trim(replace(replace(replace(replace(
	search_query,"'", ""), '[', ''), ']', ''), '"', ''), ' '
), r'\s+', '')) AS trimmed_keyword,
	LOWER(TRIM(search_query, '[],",')) AS keywords,
	(IFNULL(LENGTH(search_query), 0) - IFNULL(LENGTH(REPLACE(search_query, ' ', '')), 0) + 1) AS word_cnt,
	SUM(request) as request,
	SUM(response) as response,
	case when sum(request) > 0 then sum(response)* 100 / sum(request) else 0 end as RR,
	FROM 
	prj-onlinesales-prod-01.reporting.os_product_ads_search_query_request_report 
	where
	marketplace_client_id = "163519"
	AND date >= CURRENT_DATE - 7
	AND date <= CURRENT_DATE - 1
  GROUP BY 1,2,3
	order by request DESC;

------List of Targeted keywords from active campaigns with keyword id-------------
SELECT 
  keyword_lst.marketplace_client_id,
  camp_lst.agency_id,
  keyword_lst.keyword_id,
  keyword_lst.marketing_campaign_id,
  keyword_lst.text,
  keyword_lst.is_negative,
  keyword_lst.match_type,
  keyword_lst.status_type,
  keyword_lst.bidding_value,
  keyword_lst.bidding_currency,
  keyword_lst.bidding_value_usd
FROM (
  SELECT 
    c.agency_id agency_id,
    mcd.marketing_campaign_id marketing_campaign_id
  FROM 
    `prj-onlinesales-prod-01.reporting.marketing_campaign_dimensions` mcd,
    `prj-onlinesales-prod-01.reporting.clients` c
  WHERE
    mcd.client_id = c.client_id 
    AND c.agency_id = '361'
    AND mcd.campaign_type = "PERFORMANCE"
    AND mcd.status = "ACTIVE"
) AS camp_lst
JOIN `prj-onlinesales-prod-01.reporting.os_campaign_level_keywords_metadata` keyword_lst
ON camp_lst.marketing_campaign_id = keyword_lst.marketing_campaign_id
WHERE 
  keyword_lst.marketing_campaign_id IN (camp_lst.marketing_campaign_id)
  AND keyword_lst.is_deleted = false;
-------------Top categories for a keywords----------
s3://os-search-relevancy-data/prod/keyword_category_data_v2_10008513.csv

