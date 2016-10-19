using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using ContactManager.Models;
using WebApplication3.Models;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json.Linq;
using System.Text;

namespace WebApplication3.Controllers
{
    [AllowAnonymous]
    public class ContactsController : Controller
    {
        private ApplicationDbContext db = new ApplicationDbContext();
        private static string apiKey = "qyprdE9GEAEPxCvdttcabAjCJQGhxV";
        private static string apiSecret = "UJrrnX674PilldY8JlR5MJc7bScz7nBWXKLBwUMm";
        private static string token = "";
        private static string realmId = "";
        private static string secret = "";
        private static string oauth_verifier = "";
        private static string instanceToken = "";

        // GET: Contacts
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



            //
            //Below is Create the default object of type {objectName} for an organization. 
            //Here is for customer
             baseUri = "https://api.cloud-elements.com/elements/api-v2/organizations/objects/contact/definitions";
            string customer = @"
                {{
                    ""
                    ""fields"":[
                        {{
                            ""path"":""id"",
                            ""type"":""string""
                        }}
                    ]
                }}";
            siteRequest = new HttpRequestMessage(HttpMethod.Post, baseUri);
            siteRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            siteRequest.Headers.Authorization = new AuthenticationHeaderValue("User", string.Format("{0}, Organization {1}", user, org));
            siteRequest.Content = new StringContent(string.Format(customer), Encoding.UTF8, "application/json");

            httpClient = new HttpClient();
            siteResponse = await httpClient.SendAsync(siteRequest);
            siteResponse.EnsureSuccessStatusCode();
            text = await siteResponse.Content.ReadAsStringAsync();
            var res = JObject.Parse(text);

            

            return View(db.Contacts.ToList());
        }

        // GET: Contacts/Details/5
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Contact contact = db.Contacts.Find(id);
            if (contact == null)
            {
                return HttpNotFound();
            }
            return View(contact);
        }

        // GET: Contacts/Create
        [Authorize(Roles = "canEdit")]
        public ActionResult Create()
        {
            return View();
        }

        // POST: Contacts/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async System.Threading.Tasks.Task<ActionResult> Create([Bind(Include = "ContactId,Name,Address,City,State,Zip,Email")] Contact contact)
        {
            //if (ModelState.IsValid)
            //{
            //    db.Contacts.Add(contact);
            //    db.SaveChanges();
            //    return RedirectToAction("Index");
            //}


            //
            //Authenticate with quickbooks online through cloud element
            //
            string baseUri = "https://api.cloud-elements.com/elements/api-v2/elements/quickbooks/oauth/";
            string line = baseUri + "token?apiKey=" + apiKey + "&apiSecret=" + apiSecret + "&callbackUrl=https://localhost:44351/contacts/index";

            HttpRequestMessage siteRequest = new HttpRequestMessage(HttpMethod.Get, line);
            siteRequest.Headers.Add("Content", "application/json");
            HttpClient httpClient = new HttpClient();
            var siteResponse = await httpClient.SendAsync(siteRequest);
            siteResponse.EnsureSuccessStatusCode();
            var text = await siteResponse.Content.ReadAsStringAsync();
            var response = JObject.Parse(text);
            secret = response["secret"].ToString();
            token = response["token"].ToString();

            string url2 = baseUri + "url?apiKey=" + apiKey + "&apiSecret=" + apiSecret + "&callbackUrl=https://localhost:44351/contacts/index&requestToken=" + token + "&state=quickbooks";

            siteRequest = new HttpRequestMessage(HttpMethod.Get, url2);
            siteRequest.Headers.Add("Content", "application/json");
            siteResponse = await httpClient.SendAsync(siteRequest);
            siteResponse.EnsureSuccessStatusCode();
            text = await siteResponse.Content.ReadAsStringAsync();
            response = JObject.Parse(text);

            string oauthUrl = response["oauthUrl"].ToString();


            return Redirect(oauthUrl);
        }

        // GET: Contacts/Edit/5
        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Contact contact = db.Contacts.Find(id);
            if (contact == null)
            {
                return HttpNotFound();
            }
            return View(contact);
        }

        // POST: Contacts/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "ContactId,Name,Address,City,State,Zip,Email")] Contact contact)
        {
            if (ModelState.IsValid)
            {
                db.Entry(contact).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(contact);
        }

        // GET: Contacts/Delete/5
        public ActionResult Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Contact contact = db.Contacts.Find(id);
            if (contact == null)
            {
                return HttpNotFound();
            }
            return View(contact);
        }

        // POST: Contacts/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            Contact contact = db.Contacts.Find(id);
            db.Contacts.Remove(contact);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
