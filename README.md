# rox

A Ruby interpreter for the Lox programming language.

I've decided to follow along with the first section of Bob Nystrom's book
[Crafting Interpreters](https://craftinginterpreters.com) and
build an interpreter for the Lox programming language. This should serve two
purposes - providing a scratch for the ever nagging itch I have to understand
programming languages better, and stretch my Ruby skills beyond the usual Rails
application I write daily.

Bob has written his implementation in Java, which is convenient (for me at least) since I'll
have to 'translate' it to Ruby, meaning I'll have to really understand what's happening
behind the scenes.

Depending on how well that goes, I may continue on and write a VM for Lox (probably in C, and
depending how that goes, maybe another low level language).

**Update [April 15th 2021]**

It took longer than expected ( a lot of life happened between the start of this project and now),
but Rox is complete!

It was a very educational experience, and a very interesting one. I've gained a tremendous amount of
respect for those who design and build languages, particulalry those who aren't on a large team or
have the backing of a large organisation.

I'm not continuing with the final part of Crafting Interpreters for now (the VM in C); I'm going to
write some code of my own and hopefully apply some of the lessons I've learnt here. If you're
interested in programming languages I *highly* reccommend giving Crafting Interpreters a read (and
a follow along!), it's excellently written, humorous, and enjoyable. I don't think a lot of books
about interpreters can say that.
