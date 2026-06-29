using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SmartLedgerSystem.Models
{
    public class AccountModel
    {
        public long Id { get; set; }
        public string Code { get; set; }
        public string Name { get; set; }
        public long? ParentId { get; set; }
        public string AccountType { get; set; }
        public bool IsPostable { get; set; }
        public int Level { get; set; }
    }
}