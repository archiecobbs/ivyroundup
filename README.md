## Welcome to Ivy RoundUp

**Ivy RoundUp** is an online [Ivy](http://ant.apache.org/ivy/) repository meant to be shared by all Ivy users.

**[Click here to view the current repository contents](https://raw.githubusercontent.com/archiecobbs/ivyroundup/master/repo/modules.xml)**.

Instead of hosting Ivy module definition files (`ivy.xml` files) and artifacts together on the same site, this site hosts only the module definition files plus additional meta-data (`packager.xml` files) that describes how to download and extract the module's artifacts on-demand at the point of use.

This type of repository is made possible by the **[Packager Resolver](http://ant.apache.org/ivy/history/latest-milestone/resolver/packager.html)**, an Ivy resolver added in Ivy 2.0 that supports downloading, extracting and repackaging artifacts on-demand.

The Packager Resolver allows for a clearer separation between two jobs which don't necessarily go together: maintaining Ivy meta-data, and hosting the actual artifacts. The focus of the Ivy RoundUp project is the first task.

In addition, it's easy to use the Ivy RoundUp repository's meta-data to [build a normal repository](https://github.com/archiecobbs/ivyroundup/wiki/HowToBuildNormalRepository.md) containing artifacts.

Our goals are:
  * To maintain an Ivy repository that is:
    * **Comprehensive**: containing all of your favorite stuff
    * **Up-to-date**: rapid inclusion of newly released software
    * **Refined**: full use of Ivy's powerful configuration definitions and dependency mappings
    * **Self-consistent**: consistency in naming with respect to organizations, modules, configurations, and dependencies, according to [documented standards and guidelines](https://github.com/archiecobbs/ivyroundup/wiki/ModuleMaintainerGuidelines.md)
  * To facilitate the easy creation of a normal Ivy repository based on the Ivy RoundUp meta-data
  * To grow an active community of maintainers ([want to help?](https://github.com/archiecobbs/ivyroundup/wiki/HowToContribute.md)) each of whom is motivated by their own personal interest in, and daily use of, the modules they maintain
  * To become **the premiere community Ivy repository** on the Internet

Want to try it out? Install [the latest version of Ivy](http://ant.apache.org/ivy/download.cgi) and then configure your `ivysettings.xml` [as described here](https://github.com/archiecobbs/ivyroundup/wiki/HowToConfigureIvy.md).

Interested in learning more? Join us on the [Ivy RoundUp mailing list](http://groups.google.com/group/ivyroundup)! Or read [how you can help](https://github.com/archiecobbs/ivyroundup/wiki/HowToContribute.md) and become a [contributor](https://github.com/archiecobbs/ivyroundup/wiki/Contributors.md).

You can also view [the modules contained in Ivy RoundUp](https://raw.githubusercontent.com/archiecobbs/ivyroundup/master/repo/modules.xml) so far.
