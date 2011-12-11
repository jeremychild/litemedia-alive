using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LiteMedia.Alive.Web.Test
{
    using System.Diagnostics;

    public partial class Index : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void IncreaseCounter(object sender, EventArgs e)
        {
            using (var counter = new PerformanceCounter("Test Category", "Test Increment", readOnly: false))
            {
                counter.Increment();
            }
        }
    }
}