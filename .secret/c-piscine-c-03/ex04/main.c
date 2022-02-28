/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: xcarroll <xcarroll@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/02/26 01:21:23 by xcarroll          #+#    #+#             */
/*   Updated: 2022/02/26 02:45:47 by xcarroll         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <string.h>
#include <stdio.h>

char	*ft_strstr(char *str, char *to_find);

int	main(void)
{
	char str[] = "hire me 42";
	char find[] = "42";
	
	printf("Mine:\t\t%s\n", strstr(str, find));
	printf("Not Mine:\t%s\n", ft_strstr(str, find));
	printf("Str pointer:\t\t%p\n", str);
	printf("My pointer:\t\t%p\n", ft_strstr(str, find));
	//printf("Not my pointer:\t\t%p\n", strstr(str, find));

	//strstr(str, find)
}
