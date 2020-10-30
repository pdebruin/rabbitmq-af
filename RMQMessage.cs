using System;
using System.Collections.Generic;
using System.Text;

namespace rabbitmq
{
    class RMQMessage
    {
        public string firstName;
        public string lastName;
        public string email;

        public RMQMessage(string firstName, string lastName, string email)
        {
            this.firstName = firstName;
            this.lastName = lastName;
            this.email = email;
        }
    }
}