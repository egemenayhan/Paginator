# Paginator
Case Study

Paginator is case study focused on data fetching, pagination and infinite scroll.

### Installation:
Just open and run the project

### Project Structure:
I prefer MVVM-R pattern on my projects. MVVM-R is classic MVVM pattern with `State` and `Router` extensions. State is our data container which controlled by view model. Router is handling routing on view controller. For further information please check [this blog post](https://medium.com/commencis/using-redux-with-mvvm-on-ios-18212454d676). 

Presentation is used really simple since we have tiny data object. I do not prefer using data/network object directly in presentation for complex objects.

I like to use stackview in dynamic interfaces for easier show/hide handling.
