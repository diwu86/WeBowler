using ContactManager.Models;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Web;
using System.Web.Mvc;
using WebApplication3.Models;

namespace WebApplication3.Controllers
{
    [AllowAnonymous]
    public class SyncController : Controller
    {
        private ApplicationDbContext db = new ApplicationDbContext();
        private static string apiKey = "qyprdE9GEAEPxCvdttcabAjCJQGhxV";
        private static string apiSecret = "UJrrnX674PilldY8JlR5MJc7bScz7nBWXKLBwUMm";
        private static string token = "";
        private static string realmId = "";
        private static string secret = "";
        private static string oauth_verifier = "";
        private static string instanceToken = "";
        private static string instanceId = "";
        // GET: Sync
        public async System.Threading.Tasks.Task<ActionResult> Index()
        {
            realmId = Request.Params["realmId"].ToString();
            oauth_verifier = Request.Params["oauth_verifier"].ToString();



            //
            //Below is for creating a new instance in Cloud Element After Authentication
            //
            var baseUri = "https://api.cloud-elements.com/elements/api-v2/instances";

            string format = @"
                {{
                  ""element"": {{ 
                    ""key"": ""quickbooks"" 
                  }},
                  ""providerData"": {{
                    ""oauth_token"": ""{0}"",
                    ""oauth_verifier"": ""{1}"",
                    ""realmId"": ""{2}"",
                    ""secret"": ""{3}"",
                    ""state"": ""quickbooks"",
                    ""dataSource"": ""QBO""
                  }},
                  ""configuration"": {{
                    ""oauth.api.key"": ""{4}"",
                    ""oauth.api.secret"": ""{5}"",
                    ""oauth.callback.url"": ""https: //localhost:44351/contacts/index""
                  }},
                  ""tags"": [""QBO Token""],
                  ""name"": ""qbotest""
                }}";

            string user = "sb7IvcZZgLr9wfJJPrQTFDro+SvYlXYpChxkInxkNG8=";
            string org = "aaf184125150d0ae0376d02658a853bf";
            var siteRequest = new HttpRequestMessage(HttpMethod.Post, baseUri);
            siteRequest.Content = new StringContent(string.Format(format, token, oauth_verifier, realmId, secret, apiKey, apiSecret), Encoding.UTF8, "application/json");
            siteRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            siteRequest.Headers.Authorization = new AuthenticationHeaderValue("User", string.Format("{0}, Organization {1}", user, org));


            var httpClient = new HttpClient();
            var siteResponse = await httpClient.SendAsync(siteRequest);
            siteResponse.EnsureSuccessStatusCode();
            var text = await siteResponse.Content.ReadAsStringAsync();
            var postsInfo = JObject.Parse(text);
            instanceToken = postsInfo["token"].ToString();
            instanceId = postsInfo["id"].ToString();



            //
            //Below is Create the default object of type {objectName} for an organization. 
            //Here is for customer
            // baseUri = "https://api.cloud-elements.com/elements/api-v2/organizations/objects/contact/definitions";
            //string customer = @"
            //    {{
            //        ""
            //        ""fields"":[
            //            {{
            //                ""path"":""id"",
            //                ""type"":""string""
            //            }}
            //        ]
            //    }}";
            //siteRequest = new HttpRequestMessage(HttpMethod.Post, baseUri);
            //siteRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            //siteRequest.Headers.Authorization = new AuthenticationHeaderValue("User", string.Format("{0}, Organization {1}", user, org));
            //siteRequest.Content = new StringContent(string.Format(customer), Encoding.UTF8, "application/json");

            //httpClient = new HttpClient();
            //siteResponse = await httpClient.SendAsync(siteRequest);
            //siteResponse.EnsureSuccessStatusCode();
            //text = await siteResponse.Content.ReadAsStringAsync();
            //var res = JObject.Parse(text);

            //
            //Below is get all customers data
            //
            string customerBaseUri = "https://api.cloud-elements.com/elements/api-v2/hubs/finance/customers";
            siteRequest = new HttpRequestMessage(HttpMethod.Get, customerBaseUri);
            siteRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            siteRequest.Headers.Authorization = new AuthenticationHeaderValue("User", string.Format("{0}, Organization {1}, Element {2}", user, org, instanceToken));

            httpClient = new HttpClient();
            siteResponse = await httpClient.SendAsync(siteRequest);
            siteResponse.EnsureSuccessStatusCode();
            text = await siteResponse.Content.ReadAsStringAsync();
            var res = JArray.Parse(text);

            int length = res.Count();

            var all = from cb in db.Contacts select cb;
            db.Contacts.RemoveRange(all);
            db.SaveChanges();
            for (int i = 0; i < 3; i++)
            {
                Contact c = new Contact();
                c.Name = res[i]["displayName"].ToString();
                c.Address = res[i]["billAddr"]["line1"].ToString();
                c.City = res[i]["billAddr"]["city"].ToString();
                c.State = res[i]["billAddr"]["countrySubDivisionCode"].ToString();
                c.Zip = res[i]["billAddr"]["postalCode"].ToString();
                c.Email = res[i]["primaryEmailAddr"]["address"].ToString();
                db.Contacts.Add(c);
                db.SaveChanges();
            }
            System.IO.File.WriteAllText(@"C:\qbo\customers.json", text);

            //
            //below is to get invoices data
            //
            string invoiceBaseUri = "https://api.cloud-elements.com/elements/api-v2/hubs/finance/invoices";
            siteRequest = new HttpRequestMessage(HttpMethod.Get, invoiceBaseUri);
            siteRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            siteRequest.Headers.Authorization = new AuthenticationHeaderValue("User", string.Format("{0}, Organization {1}, Element {2}", user, org, instanceToken));

            httpClient = new HttpClient();
            siteResponse = await httpClient.SendAsync(siteRequest);
            siteResponse.EnsureSuccessStatusCode();
            text = await siteResponse.Content.ReadAsStringAsync();
            System.IO.File.WriteAllText(@"C:\qbo\invoices.json", text);

            //
            //below is to get ledger accounts data
            //
            string ledgerAccountBaseUri = "https://api.cloud-elements.com/elements/api-v2/hubs/finance/ledger-accounts";
            siteRequest = new HttpRequestMessage(HttpMethod.Get, ledgerAccountBaseUri);
            siteRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            siteRequest.Headers.Authorization = new AuthenticationHeaderValue("User", string.Format("{0}, Organization {1}, Element {2}", user, org, instanceToken));

            httpClient = new HttpClient();
            siteResponse = await httpClient.SendAsync(siteRequest);
            siteResponse.EnsureSuccessStatusCode();
            text = await siteResponse.Content.ReadAsStringAsync();
            System.IO.File.WriteAllText(@"C:\qbo\ledgerAccounts.json", text);

            //
            //below is to get products data
            //
            string productBaseUri = "https://api.cloud-elements.com/elements/api-v2/hubs/finance/products";
            siteRequest = new HttpRequestMessage(HttpMethod.Get, productBaseUri);
            siteRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            siteRequest.Headers.Authorization = new AuthenticationHeaderValue("User", string.Format("{0}, Organization {1}, Element {2}", user, org, instanceToken));

            httpClient = new HttpClient();
            siteResponse = await httpClient.SendAsync(siteRequest);
            siteResponse.EnsureSuccessStatusCode();
            text = await siteResponse.Content.ReadAsStringAsync();
            System.IO.File.WriteAllText(@"C:\qbo\products.json", text);

            return RedirectToAction("Index", "Contacts");
        }

        // GET: Sync
        public async System.Threading.Tasks.Task<ActionResult> Sync()
        {
            //
            //Authenticate with quickbooks online through cloud element
            //
            string baseUri = "https://api.cloud-elements.com/elements/api-v2/elements/quickbooks/oauth/";
            string line = baseUri + "token?apiKey=" + apiKey + "&apiSecret=" + apiSecret + "&callbackUrl=https://localhost:44351/Sync/index";

            HttpRequestMessage siteRequest = new HttpRequestMessage(HttpMethod.Get, line);
            siteRequest.Headers.Add("Content", "application/json");
            HttpClient httpClient = new HttpClient();
            var siteResponse = await httpClient.SendAsync(siteRequest);
            siteResponse.EnsureSuccessStatusCode();
            var text = await siteResponse.Content.ReadAsStringAsync();
            var response = JObject.Parse(text);
            secret = response["secret"].ToString();
            token = response["token"].ToString();

            string url2 = baseUri + "url?apiKey=" + apiKey + "&apiSecret=" + apiSecret + "&callbackUrl=https://localhost:44351/sync/index&requestToken=" + token + "&state=quickbooks";

            siteRequest = new HttpRequestMessage(HttpMethod.Get, url2);
            siteRequest.Headers.Add("Content", "application/json");
            siteResponse = await httpClient.SendAsync(siteRequest);
            siteResponse.EnsureSuccessStatusCode();
            text = await siteResponse.Content.ReadAsStringAsync();
            response = JObject.Parse(text);

            string oauthUrl = response["oauthUrl"].ToString();


            return Redirect(oauthUrl);

        }

        public ActionResult Cleanup()
        {
            var all = from cb in db.Contacts select cb;
            db.Contacts.RemoveRange(all);
            db.SaveChanges();
            return RedirectToAction("Index", "Contacts");
        }
    }
}
